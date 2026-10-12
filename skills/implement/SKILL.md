---
name: implement
description: >
  Invoke whenever the user asks to implement, build, code or continue coding a feature that
  has an approved task list or is trivial, or runs `/specd:implement [feature] [tasks]`;
  also as the next step after `/specd:tasks`, after a trivial `/specd:start`, after a review
  that sent findings back and after `/specd:feedback` turned PR comments into fix tasks. It
  runs the tasks in `tasks.md` one at a time through the implementer agent (a trivial
  feature has one implicit task from its brief), or only the selected ones (`T1-T3`,
  `T1, T4, T5`), verifies each with the project checks, stops for your approval (G4) at the
  configured granularity and on every high-risk task, proposes escalation when a light
  feature trips a signal, commits each task as a `WIP:` commit until the feature is on a PR
  (after the approval when the stop is per task), and resumes from the first open task
  after `/clear`. Not for ad-hoc coding outside a feature; that is `/specd:principles`.
---

# Skill: implement

Builds the feature task by task. The main thread orchestrates: pick a task, dispatch the
`implementer` in its own context, check its report, stop at G4 when the granularity says
so, commit, flip the task. Code never enters this conversation; the implementer's summaries
do. Task commits are `WIP:` commits until `deliver` records a PR (`deliver` offers to
squash them before the first push); fixes after that carry their plain message, they stay
in the history. On trivial there is no task list: the brief is the one task (`loop.md`).

## Gate

G3 approved (`state check --step implement`; trivial needs no gate, a fix feature needs its
reproduction). Re-entry after a G4 stop or a review round is the same command: the first
`todo` task is where it continues.

## Inputs

- Arguments: `[feature] [tasks]`; the task selection grammar is in `loop.md`.
- `resolve-paths`, `detect-repo`, `state find`, `state check`, `detect-commands`
  ([`../_shared/paths.md`](../_shared/paths.md): the opening sequence, which repo commits what).
- `<spec_root>/<feature>/tasks.md`, `state.yml`, `spec.md`, `design.md` (when present);
  `tasks/T<n>.md` when the task in hand is an index line pointing there; on trivial
  `brief.md` instead of the three.
- `<docs_root>/conventions.md`, [`../_shared/principles.md`](../_shared/principles.md) (path
  passed to the agent, read by it).
- `<workspace_root>/specd.yml`: `models.execution`, `flow.tdd`, `flow.gate_granularity`,
  `git.authority`, `layers.*` (files per task `layer`, relative to `code_root`).
- [`../_shared/gates.md`](../_shared/gates.md), [`../_shared/state-yml.md`](../_shared/state-yml.md).
- [`./references/implementer-prompt.md`](./references/implementer-prompt.md),
  [`./references/loop.md`](./references/loop.md).

## Outputs

- Code and tests in `<code_root>`, one commit per landed task (its `commit:` line, `WIP:`
  prefixed while `pr` is empty).
- `tasks.T<n>` flipped in `state.yml`; `gates.G4` stamped at each stop; `step` advanced to
  the tier's next step (`review`; `verify` on a PR; `deliver` on trivial) once no task is left.
- On escalation: `tier`, `step`, `triage.escalated` in `state.yml`; the landed files stay
  uncommitted in the tree.

## Protocol

1. **Resolve.** Split the arguments per `loop.md` into the feature and the selection.
   Resolve per `paths.md` ("Resolving for a feature"), `state check --step implement` per
   `gates.md`; `detect-commands --from <code_root>`. The current branch of `<code_root>`
   must be `branch` from `state.yml`; otherwise refuse in one line (`checkout <branch> in
   <code_root> first`, or `/specd:start` again when its worktree is gone). Set
   `step=implement`. Read `tasks.md` and `state.yml`
   once; on trivial, compose the implicit `T1` from `brief.md` per `loop.md` instead and
   show it. Validate the selection (`loop.md`): an unknown id, or a selected task whose
   dependency is neither `done` nor selected, is a refusal in one line. Show the task board
   in one line per task (`T1 done · T2 todo* …`, `*` marks selected) and, when `git status`
   shows uncommitted work from a rejected stop, the files it holds.
2. **Pick** the first `todo` task, within the selection when one was given, whose
   `depends-on` are all `done` (`loop.md`). None left with open dependencies: stop and say
   which task blocks.
3. **Dispatch** `implementer` at `models.execution` with `implementer-prompt.md` filled: the
   task verbatim (its block from `tasks.md`, or the body of `tasks/T<n>.md` when its entry
   is an index line), the ACs it covers quoted from `spec.md`, the design headings that
   apply, absolute paths of `conventions.md` and `principles.md`, then of the files under
   `layers.<task.layer>` resolved against `code_root`, the check commands, the TDD flag,
   and the earlier-attempt line when the tree holds uncommitted files for this task. A
   `layer` with no entry in `layers`, or a listed file that does not exist: dispatch without
   it and name it in the handoff `Review`. One task per dispatch, always.
4. **Land.** Show the agent's four sections as they came back. On trivial or quick, test
   the report against the escalation signals in `loop.md`; one fires: ask once, escalate
   (`state escalate --to <next tier> --signal <s>`, files stay uncommitted and are named in
   the handoff, `Next` is the step the script reported) or continue. `## Blocked` not
   "none": leave the task `todo`, end with the handoff naming the block. Otherwise run
   `git -C <code_root> status --short`; files not in `## Changed` or `## Deviations` are
   shown and left unstaged. When this task stops for G4 on its own (granularity `task`, or
   `risk: high`), leave it uncommitted and go to step 5. Otherwise commit it per
   `loop.md`: `state set tasks.T<n>=done`, stage the listed files plus `state.yml`, message
   the task's `commit:` line with the prefix `loop.md` gives (authority ≠ `none`;
   `commit: none` skips).
5. **G4 stop** when `loop.md` says so: granularity `task`; `phase` and this task ends its
   phase; `end` and no `todo` remains; `risk: high`; or the last selected task. Pass G4 per
   `gates.md` (summary: tasks landed since the last stop, files, checks run, deviations,
   which task is still uncommitted). Approve: `state set gates.G4=now`, commit the pending
   task as in step 4, continue at step 2 in this same context. Edit: one revision dispatch
   per task the request names (default: the last landed one) with the revision block of
   `implementer-prompt.md`, land it per step 4 (an already committed task gets a further
   commit), then ask again. Reject: handoff; a pending task stays `todo` with its
   files uncommitted in the tree, named under `Review`; `Next` is this command. No stop due:
   continue at step 2 without asking.
6. **Finish.** No `todo` left in the feature: run `"${CLAUDE_PLUGIN_ROOT}/scripts/run-checks"
   --from <code_root>`. Red: one repair dispatch with the failing output, commit its files
   as `fix(<scope>): make <check> pass` (prefixed per `loop.md`), re-run; still red:
   handoff with the output,
   `step` stays `implement`. Green: `state set step=next`; the script picks `review`,
   `verify` (a PR carries the human review) or `deliver` (trivial) from the tier and `pr`.
   A run that ends with `todo` tasks left (a selection, a block) skips this step. Whenever
   the run ends, a dirty `state.yml` is committed alone as `spec(<feature>): implement`.
7. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Review`: deviations the
   agents reported, tests marked as looking wrong, uncommitted files left by a reject.
   `Next: /specd:<step> <feature>` for the step reported in 6, else `/specd:implement <feature>`.

## Anti-patterns

- Writing or fixing code in the main thread "because it is a one-liner".
- Two tasks in one dispatch, or a dispatch without the task's ACs quoted.
- Pasting a layer skill's text into the prompt; the agent gets paths and reads them itself.
- Committing a task before its own G4 stop, or with the wrong prefix for the branch's
  state (`WIP: ` before the PR, none after).
- Committing files the agent did not list, or amending a task's commit.
- Widening a selection silently to pull in a dependency; refuse and name it.
- Skipping a G4 stop because the change looked small; the granularity is the user's setting.
- Repairing past the bound: three attempts inside the agent, one more dispatch at the end.
- Pushing on with a trivial or quick task after the agent reported a migration, a new
  dependency or two readings; that is the escalation question, not a judgement call.
