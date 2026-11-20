# specify on the quick tier

Quick gets a spec and its task list in one run and one gate: the spec is short, the tasks
are few, and nothing between them (design) runs. Every downstream step reads the same two
files it reads on full, so only this step knows the tier.

## Depth

One interview round (`interview.md`); leftovers are open questions with owners. The spec
template is the same; aim for at most 60 lines.

## Re-triage, before the tasks

After the interview, read the spec once more against two tests:

1. The signal table in [`../../design/references/sections.md`](../../design/references/sections.md):
   would any optional design section be selected (data model, API and contracts,
   sequences, UX flows)? Name the AC or sentence that selects it.
2. The task count the scope implies (`breakdown.md` sizing rules): more than five tasks.

Either test positive: ask one question, **escalate to full** (default) or **stay quick**
(the user accepts building without a design). Escalate: run
`../../scripts/state escalate --file <state.yml> --to full --signal
<schema|api|sequences|ux|size>`; `step` stays `specify`; continue as full from here (the
remaining interview rounds, the critic pass, no task draft, G1 only). Stay: say so in the
handoff `Review` and go on. Nothing positive: say `re-triage: quick holds` and go on.

## Tasks

Draft `<spec_root>/<feature>/tasks.md` from [`../../tasks/templates/tasks.md`](../../tasks/templates/tasks.md)
per [`../../tasks/references/breakdown.md`](../../tasks/references/breakdown.md), with these
deltas:

- Header: `Design: none (quick)`.
- One phase named for the work (`Build`, or the feature's own word) plus `Verify`. At most
  five tasks before Verify; a sixth is the escalation signal above.
- Every field as on full: `goal`, `files`, `done-when`, `depends-on`, `risk`, `layer` when
  `layers` names one, `commit`, `covers`, `tests` with `flow.tdd: true`.
- The coverage matrix has its Test column filled and Evidence empty. `verify` does not run
  on quick: the review's acceptance-criteria table is the evidence, and `deliver` shows it.

Fix features (`fix.symptom` set in `state.yml`): Problem is the symptom and its cause as the
reproduction showed it; AC1 is `<fix.repro> exits 0`; further ACs only for behaviour the fix
changes on purpose; T1 covers AC1 and its `commit:` is `fix(<scope>): <summary>`.

## The gate

One G1 question covers both files. The summary (at most ten lines) adds the task list: one
line per task with its id, goal and risk. **edit** may change either file. **approve**:
remove both draft markers, one `state set gates.G1=now gates.G3=now tasks.T1=todo …
step=next` call, commit `spec(<feature>): specify` with both files.

## Why two files and not one

A single `spec.md` with a tasks section would make `implement`, `review`, `deliver` and
`close` test the tier before every read. Two files from the same templates keep them
tier-blind; the cost is one more file in a folder that `close` deletes anyway.
