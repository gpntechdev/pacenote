# Path resolution

**Reference-only.** Not a skill. Every skill locates files through these roots; no skill
hardcodes a path.

## Roots

| Root | Meaning | Embedded default | Wrapper default |
|---|---|---|---|
| `workspace_root` | folder holding `specd.yml` | `<repo>/.specd` | `<wrapper>` |
| `code_root` | the code | `<repo>` (`paths.code_root: ".."`) | `<wrapper>/<project>` |
| `docs_root` | persistent knowledge | `<workspace_root>/docs` | `<workspace_root>/docs`, or inside the code repo if chosen at init |
| `spec_root` | working set | `<workspace_root>/spec` | `<workspace_root>/spec` |

`paths.*` in `specd.yml` are relative to `workspace_root`. Absolute paths work but do not survive
a clone, so `init` never writes them.

## Feature worktrees (wrapper mode, `git.worktrees: true`)

`<wrapper>/.worktrees/<feature>/` is a worktree of the wrapper repo on the feature branch,
holding a worktree of the code repo on the same branch at `<project>/` inside it. A worktree is
therefore a complete wrapper layout (`specd.yml`, `CLAUDE.md`, `spec/`, `docs/`, code), and
resolving from inside it yields its own roots: `workspace_root` is the worktree, `code_root` the
code worktree. `scripts/worktree` creates and removes them (`start`, `close`); the folder is
gitignored. The wrapper root sees the features inside worktrees through `state find` and
`state list --worktrees <wrapper_root>/.worktrees`.

## Finding specd.yml

From the current directory upward, at each level: `<dir>/specd.yml` (wrapper), then
`<dir>/.specd/specd.yml` (embedded). The first hit wins. No hit means the workspace is not
initialised: stop and suggest `/specd:init`.

## The script

Run the helper instead of reasoning about paths:

```
"${CLAUDE_PLUGIN_ROOT}/scripts/resolve-paths" [--from DIR] [--feature NAME]
```

It prints one JSON object: `mode`, `project`, `workspace_root`, `code_root`, `docs_root`,
`spec_root`, `config` (the file it read), `worktree` (the worktree root when the workspace is
one, else empty), `feature` (its name, else empty) and `wrapper_root` (the main checkout;
equals `workspace_root` outside a worktree). `--feature NAME` resolves from
`<wrapper_root>/.worktrees/NAME/` when that worktree exists. All paths are absolute. Exit
code 1 with a one-line message when no `specd.yml` is found.

## Resolving for a feature

Every step of the feature flow opens the same way; a skill says "resolve per `paths.md`" and
states only what it adds:

1. `resolve-paths [--feature <argument>]`.
2. `state find --spec-root <spec_root> --worktrees <wrapper_root>/.worktrees [--feature
   <argument>] [--branch <current branch of code_root>]` (order and refusals in
   [`state-yml.md`](./state-yml.md)). When its `worktree` is set and differs from the
   resolved one, run `resolve-paths --feature <feature>` again: the feature's roots are the
   worktree's.
3. `detect-repo --from <code_root>`: git facts (branch, default branch, remote, host) are the
   code repo's. The wrapper's own facts, when a step needs them (`deliver`, `close`), come
   from `detect-repo --from <workspace_root>`.
4. `state check --file <state.yml> --step <name>` per [`gates.md`](./gates.md).

## Rules

- Name locations by root, never by literal folder: `<docs_root>/project.md`,
  `<spec_root>/<feature>/state.yml`, not `docs/project.md`.
- Git runs in the repo that contains the path, named by root: code with `git -C <code_root>`,
  spec files and sources with `git -C <workspace_root>`, docs with `git -C <docs_root>`. In
  embedded mode these are one repo; in wrapper mode the first is the code repo and the other
  two the wrapper (or the code repo again when `docs_root` points inside it). A skill never
  tests the mode; it names the root.
- A commit that would stage files from two roots is two commits, one per repo.
- Subagents receive resolved absolute paths in their prompt; they do not resolve on their own.
