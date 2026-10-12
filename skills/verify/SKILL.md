---
name: verify
description: >
  Invoke whenever the user asks to verify the feature, check acceptance-criteria coverage,
  fill the evidence matrix, or runs `/specd:verify [feature]`; also as the next step after a
  clean `/specd:review`. It runs the project checks, confirms every acceptance criterion has
  evidence (a passing named test, a green check, or a manual note you give), writes that
  evidence into the coverage matrix in `tasks.md` and hands off to docs (or straight to
  deliver when the feature is already on a PR). Not for running the app end to end; that is
  runtime-verify, a later milestone.
---

# Skill: verify

Fills the evidence column of the coverage matrix. Evidence is something that ran: a named
test in a green suite, a green check, or a manual note the user gives with a date. The
implementer's summaries are not evidence.

## Gate

`state check --step verify`: `step` is `verify` or later (full tier only; on quick the
review's AC table stands as evidence, trivial has no acceptance criteria).

## Inputs

- `resolve-paths`, `state find`, `state check`, `run-checks`.
- `<spec_root>/<feature>/tasks.md` (matrix), `spec.md` (AC text), `state.yml`.
- `<workspace_root>/specd.yml`: `git.authority`.
- [`../_shared/paths.md`](../_shared/paths.md), [`../_shared/gates.md`](../_shared/gates.md), [`../_shared/state-yml.md`](../_shared/state-yml.md).

## Outputs

- The matrix in `tasks.md` with every Evidence cell filled; `step: docs` in `state.yml`
  (`deliver` when `pr` is set).
- One commit `spec(<feature>): verify` (authority ≠ `none`).

## Protocol

1. **Resolve** per `paths.md` ("Resolving for a feature"), `state check --step verify` per
   `gates.md`. Set `step=verify`.
2. **Run.** `"${CLAUDE_PLUGIN_ROOT}/scripts/run-checks" --from <code_root>`. Any red check:
   stop, show its tail, handoff `Next: /specd:implement <feature>`.
3. **Automated evidence.** For each matrix row whose Test names a test case: `grep` the
   name under `<code_root>` (skip vendored folders); found and the test suite green →
   `test <name> passed (<test command>, <date>)`; not found → `missing`. Rows whose Test
   names a check (`lint`, `typecheck`, `build`, a command) → that check's result and date.
4. **Manual evidence.** Rows marked `manual`, and rows now `missing` that the user prefers
   to attest: ask for a note per AC in one grouped question (what was checked, what was
   seen); record `manual: <note> (<date>)`. Never write a note the user did not give.
5. **Gaps.** Show the matrix. A row still `missing`: offer to add a task (append to
   `tasks.md` under `Verify fixes`, `state set tasks.T<k>=todo step=implement`, handoff to
   `/specd:implement`) or to accept it with a reason written into the cell. All rows filled:
   `state set step=next` (`docs`, or `deliver` when `pr` is set: the record was written
   before the PR), then commit with `git -C <workspace_root>`.
6. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Review`: manual and
   accepted rows. `Next: /specd:<step> <feature>` with the step reported; when it is
   `deliver` on a PR, one line: run `/specd:docs` first if the fixes changed what the
   feature record says.

## Anti-patterns

- Copying "verified" from the implementer's report into the matrix.
- Inventing a manual note, or dating one with anything but today.
- Editing test names in the matrix to match what exists; a mismatch is a `missing`.
- Running checks one by one by hand; `run-checks` is the record.
