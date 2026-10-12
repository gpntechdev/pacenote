---
name: review
description: >
  Invoke whenever the user asks to review the implemented feature, check the diff against
  the spec, or runs `/specd:review [feature]`; also as the next step after
  `/specd:implement` finishes. It writes the feature's diff to disk, dispatches the reviewer
  agent in a fresh context with only the spec, design, tasks, conventions and the diff,
  records its findings in `review.md`, resolves each one with you (fix, accept, dispute),
  turns the fixes into new tasks and sends the flow back to implement, or forward to verify
  when nothing is left. Not for ad-hoc code review outside a feature.
---

# Skill: review

An independent pass over the whole feature diff by an agent that did not write it and sees
only the artifacts. Findings are the user's to resolve; fixes become tasks, so the loop
back to `implement` uses the same machinery as the first pass. Specialist passes
(security, performance, accessibility, tests) arrive with M6.

## Gate

`state check --step review`: `step` is `review` or later (full and quick; trivial has no
review). Round `review.round + 1`; a fourth round is refused: the user decides to ship or
stop by hand.

## Inputs

- `resolve-paths`, `detect-repo` (default branch), `state find`, `state check`.
- `<spec_root>/<feature>/spec.md`, `design.md` (when present), `tasks.md`, `state.yml`,
  `review.md` (earlier rounds).
- `<docs_root>/conventions.md`, [`../_shared/principles.md`](../_shared/principles.md) (path
  for the agent).
- `<workspace_root>/specd.yml`: `models.judgment`, `git.authority`, `layers.*`.
- [`../_shared/paths.md`](../_shared/paths.md), [`../_shared/gates.md`](../_shared/gates.md),
  [`../_shared/state-yml.md`](../_shared/state-yml.md).
- `./templates/review.md`, [`./references/reviewer-prompt.md`](./references/reviewer-prompt.md).

## Outputs

- `<spec_root>/<feature>/review.md` with a new `## Round n` section; `review.diff` written
  for the agent and deleted before the commit.
- Fix tasks appended to `tasks.md` and mirrored in `state.yml`; `review.round`,
  `review.open`, `step` (`implement` or `verify`).
- One commit `spec(<feature>): review round <n>` (authority ≠ `none`).

## Protocol

1. **Resolve** per `paths.md` ("Resolving for a feature"), `state check --step review`
   per `gates.md`. Round = `review.round + 1`; refuse a fourth. Set `step=review`.
2. **Diff.** `git -C <code_root> diff <default branch>...HEAD` into
   `<spec_root>/<feature>/review.diff`, excluding `<spec_root>` and `<docs_root>` paths;
   show `--stat` to the user. An empty diff: say so and stop (`Next: /specd:implement`).
3. **Dispatch** `reviewer` at `models.judgment` with `reviewer-prompt.md` filled: absolute
   paths, the layer files for every `layer` the feature's tasks name (`layers.*`, resolved
   against `code_root`, missing ones dropped), the round, the changed-file list, earlier
   findings marked accepted or disputed.
4. **Record.** Create `review.md` from `./templates/review.md` on round 1; append
   `## Round n` with the AC table, the findings and the verdict as they came back. Delete
   `review.diff`.
5. **Resolve** each finding with the user, most severe first, at most four per question:
   **fix** (append a task to a `Review fixes (round n)` phase in `tasks.md` with the finding's
   fix as goal, `covers: F<n>` plus the AC when one is named, a `commit:` line, `risk` from
   the finding, inline unless its body would pass the heavy-task threshold in
   `breakdown.md`; `state set tasks.T<k>=todo`), **accept** (one-line reason recorded), or
   **dispute** (recorded as accepted with the user's reason). A `missing` AC cannot be
   accepted; it is a fix or the spec changes (`/specd:specify`, which re-runs the flow).
6. **Route.** `state set review.round=<n> review.open=<fix count>`. Fixes: `step=implement`,
   `Next: /specd:implement <feature>` then this command again. None: `state set step=next`
   (`verify` on full, `deliver` on quick, where this round's AC table is the evidence),
   `Next: /specd:<step> <feature>` with the step it reported. Commit `review.md`,
   `tasks.md`, `state.yml` with `git -C <workspace_root>`.
7. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Review`: accepted findings
   the user may want to revisit, the verdict.

## Anti-patterns

- Reviewing in the main thread, or giving the agent the conversation's history.
- Fixing a finding here "since it is small"; fixes are tasks, so they get a commit and G4.
- Accepting a `missing` AC to move on.
- Leaving `review.diff` on disk or in the commit.
- Re-litigating a finding accepted in an earlier round.
