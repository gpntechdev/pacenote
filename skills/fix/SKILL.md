---
name: fix
description: >
  Invoke whenever the user reports a bug, regression, crash or wrong behaviour and wants it
  fixed through the workflow, or runs `/specd:fix <feature> [--from <path>]`. It opens the
  feature like `/specd:start` does (brief, state, branch) at the quick tier, localises the
  symptom with one codebase scan, and insists on a reproduction before anything else: a
  failing test it writes or a command you give that exits non-zero today. Only once that is
  recorded does it hand off to `/specd:specify`, whose first acceptance criterion is the
  reproduction passing. Not for new behaviour (`/specd:start`) and not for fixing code in
  the main thread.
---

# Skill: fix

A bug is a quick feature with one extra rule: reproduce first. The reproduction is the
contract (`fix.repro` in `state.yml`), the regression test and the first acceptance criterion
in one. Until it is recorded, `state check` refuses `specify` and `implement` for this
feature, so no spec and no code can get ahead of it.

## Inputs

- `resolve-paths`, `detect-repo`, `detect-commands` (the test command), `state find`.
- The arguments: feature name, `--from <path>`, pasted text or a sentence (the symptom).
- `<docs_root>/project.md`, `architecture/overview.md`, `conventions.md` when present.
- `<workspace_root>/specd.yml`: `git.authority`, `git.ticket_key`, `models.cheap`,
  `models.execution`.
- [`../start/SKILL.md`](../start/SKILL.md) steps 2 (place: the worktree), 3–4 (intake, brief)
  and 7–8 (branch, commit), followed as written; [`../_shared/paths.md`](../_shared/paths.md); [`../_shared/state-yml.md`](../_shared/state-yml.md),
  [`../_shared/no-attribution.md`](../_shared/no-attribution.md) (branch `fix/<slug>`),
  [`../_shared/principles.md`](../_shared/principles.md) (path for the implementer).
- [`./references/reproduce.md`](./references/reproduce.md): explorer prompt, test-only
  implementer prompt, recording rules.

## Outputs

- `<spec_root>/<feature>/brief.md`, `state.yml` (`tier: quick`, `retention: clean`,
  `fix.symptom`, then `fix.repro` and `fix.reproduced`), the branch, commit
  `spec(<feature>): fix`.
- The reproduction test in `<code_root>`, committed `WIP: test(<scope>): reproduce …` when
  it fails as expected; left uncommitted when it does not.

## Protocol

1. **Resolve.** `resolve-paths` (no config: `run /specd:init first`), `detect-repo --from
   <code_root>`, `detect-commands --from <code_root>`. Feature name as in `start`. The folder exists: `fix.symptom` set and
   `fix.reproduced` empty → resume at step 4 (the brief is on disk); otherwise `already
   started; run /specd:status` and the handoff.
2. **Place, intake and brief** per `start` steps 2–4 (the worktree, when `git.worktrees`
   is on, exists before the brief is written). The brief's "Not said" must name expected
   behaviour and actual behaviour when the input gives only one of them; ask for the
   missing one before writing, in a single question.
3. **State and branch.** `"${CLAUDE_PLUGIN_ROOT}/scripts/state" init --file <state.yml>
   --feature <feature> --tier quick --retention clean --branch <fix/<slug> or
   <KEY>-<n>-<slug>>`, then `state set triage.proposed=quick fix.symptom="<one line, no
   double quotes>"`. Branch and commit per `start` steps 7–8 (`--worktree` on `state init` when step 2
   placed one), message `spec(<feature>): fix`.
4. **Localise** per `reproduce.md`: one `explorer` run at `models.cheap`; show at most ten
   lines of candidates, nearest tests and the test convention.
5. **Reproduce** per `reproduce.md`: ask test or command; dispatch the test-only
   `implementer` at `models.execution` when a test. Run the resulting command yourself
   from `code_root`. Fails for the symptom's reason: `state set fix.repro='<cmd>'
   fix.reproduced=now`, commit the test. Passes or fails for another reason: say `not
   reproduced; no spec or code until it is`, show the tail, leave `fix.reproduced` empty,
   handoff `Next: /specd:fix <feature>`.
6. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Review`: the
   reproduction command, expected vs actual, the explorer's candidates. `Next:
   /specd:specify <feature>` (quick: spec and tasks in one gate, AC1 is the reproduction).

## Anti-patterns

- Fixing the bug while writing the reproduction; the test dispatch touches no production code.
- Recording a reproduction the main thread did not run, or one that fails for a missing
  fixture rather than the bug.
- Running triage; a fix is quick by definition and escalates like any quick feature.
- Guessing the expected behaviour; when the brief does not state it, the user does.
- Chaining commands into `fix.repro`; one command, or a script committed with the test.
