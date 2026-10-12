---
name: tasks
description: >
  Invoke whenever the user asks to break a designed feature into tasks, plan the work, write
  the task list or test plan, or runs `/specd:tasks [feature]`; also as the next step after
  `/specd:design`. It reads the spec and design, writes `tasks.md` (phases, tasks of at most
  a day with a verifiable done-when, a fixed commit message, a tests block when TDD is on)
  and the acceptance-criterion coverage matrix, asks you to approve the list (G3), mirrors
  the task ids into `state.yml` and commits. Not for writing code; that is `/specd:implement`.
---

# Skill: tasks

Turns the agreement (spec) and the plan (design) into an ordered list of small, provable
tasks. The coverage matrix at the end is the test plan: every acceptance criterion maps to a
task and, with TDD on, to the test that proves it; `verify` fills the evidence column later.

## Gate

G1 approved, and G2 when `design.md` exists (`state check --step tasks`). `rerun: true`
clears G3..G5 on write; tasks already `done` stay `done`.

## Inputs

- `resolve-paths`, `detect-repo`, `state find`, `state check`.
- `<spec_root>/<feature>/spec.md`, `design.md` (when present), `state.yml`.
- `<docs_root>/conventions.md` (test layout, naming, commit scopes), `project.md` (commands).
- `<workspace_root>/specd.yml`: `flow.tdd`, `flow.gate_granularity`, `git.authority`,
  `layers.*` (the `layer` vocabulary).
- [`../_shared/paths.md`](../_shared/paths.md), [`../_shared/gates.md`](../_shared/gates.md), [`../_shared/state-yml.md`](../_shared/state-yml.md).
- `./templates/tasks.md`, [`./references/breakdown.md`](./references/breakdown.md).

## Outputs

- `<spec_root>/<feature>/tasks.md`, plus `tasks/T<n>.md` for each heavy task (see
  `breakdown.md`); `tasks.T<n>` keys, `gates.G3`, `step: implement` in `state.yml`.
- One commit `spec(<feature>): tasks` (authority ≠ `none`).

## Protocol

1. **Resolve** per `paths.md` ("Resolving for a feature"), `state check --step tasks` per
   `gates.md`. Set `step=tasks`.
2. **Draft.** Copy `./templates/tasks.md` to `<spec_root>/<feature>/tasks.md` and fill it
   per `breakdown.md` (a `tasks.md` that already exists, from a quick feature escalated to
   full or from an earlier run, is revised in place: ids and `done` tasks stay, new tasks
   get new ids): phases in build order, tasks `T1..` in dependency order, each with
   `goal`, `files`, `done-when`, `depends-on`, `risk`, `commit`, `covers`, a `layer` when
   `specd.yml` `layers` names one it touches, and with `flow.tdd: true` a `tests:` block
   naming the test cases derived from the ACs it covers.
   The last phase is always `Verify` with one task: every project check green. **Heavy
   tasks:** a task whose body would pass about 100 lines first gets the split question (is
   it really one unit?); when it is, its body goes to `tasks/T<n>.md` from
   `./templates/task.md` and its entry in `tasks.md` is the one index line
   `- T<n> · <goal> · risk <low|high> · covers <ACs> · tasks/T<n>.md`. Every other task
   stays inline; the file's own length does not matter.
3. **Matrix.** Fill the coverage matrix: one row per AC, the task(s) and test(s) that cover
   it, evidence empty. An AC with no task gets one now, or goes back to `spec.md` as an open
   question with a line in the handoff saying so. A task covering no AC is either a
   prerequisite (say which task needs it) or is dropped.
4. **G3** per `gates.md`: path plus at most ten lines (phase list with task counts, the
   high-risk tasks by id, ACs without a test, total tasks). `edit` means the user changes,
   merges or removes tasks; renumber only before approval. Approve: remove the marker,
   `state set tasks.T1=todo … gates.G3=now step=implement` (one `set` call), commit
   `spec(<feature>): tasks`.
5. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Review`: the high-risk
   tasks and any AC left without automated evidence. State the granularity in force
   (`flow.gate_granularity`) and that `/specd:config flow.gate_granularity=task|phase|end`
   changes it. `Next: /specd:implement <feature>`.

## Anti-patterns

- A task without a command or observable in `done-when`, or one that takes more than a day.
- Tasks that mirror the design's headings instead of the build order.
- A "misc" or "cleanup" task; every task traces to an AC or to a task that does.
- Renumbering after G3; review appends new ids, it never reuses them.
- A file for a task that fits inline, or an inline block past the threshold; the unit that
  decides is the task, never the file.
- Writing test code here; the tests block names cases, `implement` writes them.
