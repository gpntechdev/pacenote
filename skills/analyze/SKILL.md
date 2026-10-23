---
name: analyze
description: >
  Invoke whenever the user asks whether a feature's spec, design and tasks agree, wants a
  consistency or coverage check across them, asks which acceptance criterion has no task,
  which task covers nothing, which design decision nothing builds, or whether the files use
  the same terms, or runs `/specd:analyze [feature]`. A script checks the coverage (AC →
  task → matrix, design's changed files → tasks) and the `analyst` agent, in a fresh context,
  judges what needs reading (decisions no task implements, inconsistent terms, a task that
  contradicts its AC). It prints one report with `path:line` per finding, writes nothing and
  names the step that owns each fix. Not for one artifact's own holes (that is
  `/specd:critique`) or for code against the spec (that is `/specd:review`).
---

# Skill: analyze

The cross-artifact check. The `critic` judges one file; this judges whether `spec.md`,
`design.md` and `tasks.md` (with its coverage matrix) say the same thing. A read-only util
per [`../_shared/utils.md`](../_shared/utils.md): no `state check`, no write, no commit. It
runs at any step once `tasks.md` exists, before or after G3.

## Inputs

- `resolve-paths` and `state find` ([`../_shared/paths.md`](../_shared/paths.md), "Resolving
  for a feature", steps 1 and 2); the argument: a feature, or none.
- `<spec_root>/<feature>/state.yml`: `tier`, `step`.
- `"${CLAUDE_PLUGIN_ROOT}/scripts/analyze" scan` output: the ACs, the tasks with their
  covers and files, the decisions, every coverage finding with `file:line`, and the decision
  candidates.
- `<workspace_root>/specd.yml`: `models.judgment`.
- [`./references/analyst-prompt.md`](./references/analyst-prompt.md) (dispatch prompt and
  report format).
- The artifacts themselves are read by the agent, not by the main thread.

## Outputs

- None on disk. The report is printed.

## Protocol

1. **Resolve.** `resolve-paths` (no config: `run /specd:init first`), then `state find`
   per `paths.md`. No feature, or several: ask which. Tier `trivial`: say there is no spec
   or tasks to compare and end with the handoff (`Next: none`).
2. **Scan.** `"${CLAUDE_PLUGIN_ROOT}/scripts/analyze" scan --feature-dir
   <spec_root>/<feature>`. A refusal names the step to run first (`/specd:specify`,
   `/specd:tasks`): print it and end with the handoff. Print `analyze: <n> coverage
   findings, <d> decisions no task names, design <present|absent>`.
3. **Dispatch** `analyst` at `models.judgment` with the prompt in `analyst-prompt.md`:
   absolute paths of `spec.md`, `design.md` (when the scan says present), `tasks.md` and
   each `tasks/T<n>.md` an index line names; the script's findings as settled; the
   decision candidates. Never add the conversation, the code, `brief.md` or `review.md`.
4. **Report** per `analyst-prompt.md` "Report": the script's findings as `S<n>` rows in
   its order, then the agent's `A<n>` rows verbatim, every row with `path:line` relative to
   the feature folder. Then one line per owning step that has rows: which rows it fixes.
   Nothing found by either: `analyze: the artifacts agree`.
5. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced: none`.
   `Review`: the rows that block G3 or the next gate (an uncovered AC, a decision nothing
   builds). `State: analyze`. `Next`: the earliest owning step with rows
   (`/specd:specify <feature>`, `/specd:design <feature>`, `/specd:tasks <feature>`), with
   one line saying a re-run clears the later gates; none: the command the user was running.

## Anti-patterns

- Fixing a row here, even "a one-line matrix fix"; the owning step rewrites its file at
  its gate.
- Reading the artifacts in the main thread to judge them; the script counts, the agent
  reads.
- Re-ranking, merging or dropping an agent finding before printing it.
- Running it on a trivial feature or before `tasks.md` exists; there is nothing to compare.
- Opening the code; agreement between the artifacts is this check, the code against them
  is `review`.
