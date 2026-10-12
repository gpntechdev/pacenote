---
name: scaffold
description: >
  Invoke whenever the user asks to scaffold, bootstrap or build the project skeleton, set up
  the initial structure and tooling of a new project, or runs `/specd:scaffold`. Greenfield
  only, after `/specd:onboard architecture` is signed off: it turns the architecture overview
  into a task list you approve (G3), builds structure, tooling, one smoke test and hygiene
  files in the main thread, proves build, test and lint pass, asks you to approve the diff
  (G5), records the commands in `specd.yml` and commits. Not for adding features to an
  existing codebase.
---

# Skill: scaffold

Materialises the skeleton that the architecture section planned, as a quick-tier feature
named `scaffold` so it gets a task gate and a delivery gate like any other work. The build
runs in the main thread because the skeleton is small and gets no reviewer pass.

## Gate

Before anything else, run `"${CLAUDE_PLUGIN_ROOT}/scripts/detect-repo"` and read
`<spec_root>/scaffold/state.yml` if it exists. Refuse with one line and the handoff block when:

- kind is `brownfield` (the repo already has code): `scaffold is for greenfield repos`;
- `<docs_root>/architecture/overview.md` is missing or starts with `<!-- specd:draft -->`:
  `run /specd:onboard architecture first`;
- `state.yml` exists with `step: closed`: `already scaffolded`.

A `state.yml` with another `step` means resume from that step.

## Inputs

- `"${CLAUDE_PLUGIN_ROOT}/scripts/resolve-paths"` output.
- `<docs_root>/architecture/overview.md`: `## Stack`, `## Structure`, `## Tooling`,
  `## Testing strategy`. `<docs_root>/conventions.md` when present.
- `<workspace_root>/specd.yml`: `project`, `flow.tdd`.
- [`../_shared/principles.md`](../_shared/principles.md), read before writing any file.
- [`../_shared/paths.md`](../_shared/paths.md) (which repo commits what),
  [`../_shared/gates.md`](../_shared/gates.md), [`../_shared/state-yml.md`](../_shared/state-yml.md).
- `./templates/tasks.md`.

## Outputs

- `<spec_root>/scaffold/tasks.md` and `state.yml`.
- The skeleton under `<code_root>`: structure, tooling configs, one smoke test, `.gitignore`,
  README stub.
- `commands.*` in `specd.yml`; `## Run, test, lint` and `## Layout` in `<docs_root>/project.md`.
- One commit `chore: scaffold project skeleton`.

## Protocol

1. **Open the feature.** Create `<spec_root>/scaffold/`. Write `state.yml` from the default in
   `state-yml.md` with `feature: scaffold`, `tier: quick`, `retention: clean`, `step: tasks`,
   timestamps set. Copy `./templates/tasks.md` and fill every placeholder from `overview.md`;
   drop a task only when its section says "none"; add `tasks: {T1: todo, …}` to `state.yml`.
2. **G3.** Pass the gate per `gates.md` on `tasks.md`. Set `step: implement`.
3. **Build.** Apply `principles.md`. For each task in order: create only the files it names,
   in the stack's mainstream layout, then run its done-when command and flip the task to
   `done` in `state.yml`. Tooling versions: the ones `overview.md` names; when it names none,
   the latest stable that the package manager resolves, recorded in the manifest.
4. **Prove it.** Run `"${CLAUDE_PLUGIN_ROOT}/scripts/detect-commands" --from <code_root>`; run build, test and
   lint (and typecheck, format check when present). A failing command gets at most three
   repair attempts; after that, stop, leave `state.yml` at `implement`, and end with the
   handoff block naming the failing command and its last output.
5. **G5.** Show `git -C <code_root> status --short` and a diff summary (files and line counts,
   not the diff). Pass the gate per `gates.md`.
6. **Record.** Run `"${CLAUDE_PLUGIN_ROOT}/scripts/config-set" --file <config>` with each
   non-empty `commands.*`. Replace the `## Run, test, lint` and `## Layout` sections of
   `<docs_root>/project.md` with the real commands and tree. Set `step: closed`.
7. **Commit.** `chore: scaffold project skeleton` with `git -C <code_root>` covering the
   skeleton, and the spec folder and docs change with it when they are in the same repo
   (embedded); in a wrapper those two go in a second commit of the same message with
   `git -C <workspace_root>`. No attribution.
8. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Next`: `/specd:start <feature>`;
   mention `/specd:toolsmith` as the later step for project skills and MCPs. Note that
   `<spec_root>/scaffold/` is a closed quick feature with `retention: clean`;
   `/specd:close scaffold` removes it.

## Anti-patterns

- Adding tooling, libraries or folders that `overview.md` does not name.
- A second test, an example feature, or placeholder business logic.
- Committing before G5, or retrying a failing command past the bound.
- Editing `overview.md` to match what was built; the doc is the input, not the output.
