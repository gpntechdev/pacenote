# Wrapper init

Read by `init` when the mode is wrapper. The wrapper is the user's own git repo around the
code repo (PLAN 3.1): specd files, docs and specs live here, the code repo sits inside,
gitignored, and gets zero files from init unless the user sends `docs/` there.

## Deciding the mode

| Signal | Mode |
|---|---|
| `--wrapper` given (with or without an argument) | wrapper |
| `detect-repo` reports `source_files: 0`, no manifests and exactly one `nested_repos` entry | propose wrapper around it; one question: wrapper (default) / embedded |
| anything else | embedded, as before |

## The code repo

- `--wrapper <folder>`: a folder directly inside the current directory that is a git repo.
  A path outside (`../app`) is refused in one line: the assistant's file tools reach only
  the folder it runs in, so move the repo in (`mv ../app .`) or clone it and re-run.
- `--wrapper <url>`: `git clone <url>` into the current directory; the folder name is the
  repository name. A clone that fails ends the run with git's message.
- No argument: the single `nested_repos` entry; several: ask which one.

The wrapper itself must be a git repo: `detect-repo` from the current directory says
`git: false` → ask whether to run `git init`; on no, stop.

## Detection runs on the code repo

`detect-repo --from <code>` and `detect-commands --from <code>`: project name, remote host,
ticket key, greenfield or brownfield and the commands all describe the code, never the
wrapper. The wrapper's own `detect-repo` output is used only for `git`.

## Interview

The embedded questions minus private mode (the wrapper is the user's repo, nothing to hide)
plus one:

- where `docs/` lands: **wrapper** (default; invisible to the client) or **inside the code
  repo** at `<code>/docs` (the docs ship with the code and ride the feature branch).

## Create and configure

```
"${CLAUDE_PLUGIN_ROOT}/scripts/init-workspace" --root <wrapper> --mode wrapper --code <name> [--docs <name>/docs]
"${CLAUDE_PLUGIN_ROOT}/scripts/config-set" --file <wrapper>/specd.yml mode=wrapper project=<name> \
  paths.code_root=./<name> [paths.docs_root=<name>/docs] git.pr_host=<host> git.ticket_key=<key> commands.<k>=<v> ...
```

`init-workspace` writes `specd.yml`, `docs/` (or the chosen folder), `spec/`, `sources/`,
`.claude/settings.json`, `.mcp.json`, `CLAUDE.md` and a `.gitignore` holding `<name>/` and
`.worktrees/`. `git.worktrees` stays `false`: parallel features are opt-in with
`/specd:config git.worktrees=true` (`paths.md`, "Feature worktrees").

## Commits

`chore: initialise specd workspace` in the wrapper, staging what the script created or
merged. When `docs/` went into the code repo, a second commit there, `docs: add specd
knowledge folder`, on its current branch, so the client tree is clean; say so in the handoff.

## Handoff additions

- "Launch the assistant in this folder; `<name>/` is the code." A session inside the code
  folder finds no `specd.yml` and the wrapper's settings do not apply there.
- "Parallel features: `/specd:config git.worktrees=true`, then each `/specd:start` opens a
  worktree under `.worktrees/`."
