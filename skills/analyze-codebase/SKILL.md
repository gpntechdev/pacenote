---
name: analyze-codebase
description: >
  Invoke whenever the user asks where the risky or tangled parts of the codebase are: change
  hotspots, the files that change most, how modules depend on each other, import cycles,
  coupling, which code has no tests, or runs `/specd:analyze-codebase [path]`. A script ranks
  files by commits times size from git history, maps imports to a module graph with fan-in,
  fan-out and cycles, and lists source files no test names; one `explorer` run at the cheap
  role then says what the top hotspots and each cycle are, with `path:line`. It prints one
  report and writes nothing. Not for a feature's artifacts (that is `/specd:analyze`) or for
  writing the architecture docs (that is `/specd:onboard architecture`).
---

# Skill: analyze-codebase

A map of where the code is hard to change. Numbers come from a script (git history, import
lines, file names); the explorer only explains the few places the numbers point at. A
read-only util per [`../_shared/utils.md`](../_shared/utils.md): no feature, no `state
check`, no write, no commit.

## Inputs

- `resolve-paths` ([`../_shared/paths.md`](../_shared/paths.md)); the argument: a path
  under `<code_root>` to narrow the scan, or none.
- `<workspace_root>/specd.yml`: `models.cheap`.
- `"${CLAUDE_PLUGIN_ROOT}/scripts/analyze-codebase" scan` output: hotspots, modules,
  cycles with their import lines, test gaps, unsupported languages.
- `<docs_root>/architecture/overview.md` when present: its area names, to label modules.
- [`./references/explorer-prompt.md`](./references/explorer-prompt.md) (dispatch prompt
  and report format).

## Outputs

- None on disk. The report is printed.

## Protocol

1. **Resolve.** `resolve-paths` (no config: `run /specd:init first`). The argument, when
   given, must lie under `<code_root>`; else say so and stop.
2. **Scan.** `"${CLAUDE_PLUGIN_ROOT}/scripts/analyze-codebase" scan --code-root
   <code_root> [--path <argument>]`, plus `--skip <root>` for each of `<workspace_root>`,
   `<docs_root>` and `<spec_root>` that lies inside `<code_root>` (embedded mode). Print
   `analyze-codebase: <source> files, <tests> tests, <modules> modules, <cycles> cycles,
   <untested> untested`. No source files: say which extensions were found
   (`unsupported`) and end with the handoff.
3. **Dispatch** one `explorer` at `models.cheap` with the prompt in `explorer-prompt.md`:
   the top five hotspots and every cycle's closing import lines (at most three cycles),
   with absolute paths. Skip the dispatch when there is neither.
4. **Report** per `explorer-prompt.md` "Report": hotspots, coupling, cycles, test gaps,
   each a short table from the script's numbers, with the explorer's one line per hotspot
   and cycle. Label modules with the overview's area names when they match.
5. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced: none`.
   `Review`: the cycles, the hotspots with no test, and that imports are a lower bound
   (unparsed languages and aliased paths are missing). `State: analyze-codebase`. `Next`:
   `/specd:onboard architecture` when the module graph contradicts
   `architecture/overview.md`, else the command the user was running, or `none`.

## Anti-patterns

- Reading or grepping the code in the main thread; the script counts, the explorer reads
  the few files it names.
- Turning the report into tasks, docs or a refactoring plan; the user decides what to act on
  and starts a feature for it.
- Presenting a missing edge as proof of independence; unresolved imports are ignored.
- Running it per feature; it maps the codebase, `/specd:analyze` checks a feature.
