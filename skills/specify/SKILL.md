---
name: specify
description: >
  Invoke whenever the user asks to write, draft or refine the spec, requirements or
  acceptance criteria for a started feature, or runs `/specd:specify [feature]`; also as the
  next step after `/specd:start` or `/specd:fix`. It turns `brief.md` into `spec.md` through
  a short interview (problem, scope, out of scope, verifiable acceptance criteria, open
  questions), runs the critic pass on the full tier, asks you to approve it (G1) and
  commits. On the quick tier it also drafts `tasks.md` and the one gate approves both. Not
  for opening a feature (`/specd:start`) or for designing how it is built (`/specd:design`).
---

# Skill: specify

Writes *what we agreed to build*. The draft goes to disk before the first question, every
answer lands in the file as it arrives, and the gate summary is the user's view of it. On
quick the task list is drafted here too ([`./references/lite.md`](./references/lite.md)); on
full the critic reads the spec before the gate.

## Gate

`state check --step specify` must pass (trivial has no spec; a fix feature needs its
reproduction first). `rerun: true` (a spec already approved) clears G1..G5 on write; ask
before continuing.

## Inputs

- `resolve-paths`, `detect-repo` (current branch), `state find`, `state check`.
- `<spec_root>/<feature>/brief.md` and `state.yml` (tier, triage signals, `fix.*`).
- `<docs_root>/project.md`, `<docs_root>/conventions.md` when present; `sources/<feature>-*.md`
  when the brief cites them.
- `<workspace_root>/specd.yml`: `flow.critic`, `flow.tdd`, `models.judgment`, `git.authority`,
  `layers.*` (quick: the `layer` vocabulary for tasks).
- [`../_shared/paths.md`](../_shared/paths.md), [`../_shared/gates.md`](../_shared/gates.md),
  [`../_shared/state-yml.md`](../_shared/state-yml.md), [`../_shared/critic.md`](../_shared/critic.md).
- `./templates/spec.md`, [`./references/interview.md`](./references/interview.md),
  [`./references/lite.md`](./references/lite.md) (quick: re-triage, tasks, the gate).

## Outputs

- `<spec_root>/<feature>/spec.md`; `gates.G1` and `step` in `state.yml`. Quick: also
  `tasks.md`, `gates.G3` and the `tasks.T<n>` keys.
- One commit `spec(<feature>): specify` (authority ≠ `none`).

## Protocol

1. **Resolve** per `paths.md` ("Resolving for a feature": `resolve-paths`, `state find`,
   `detect-repo --from <code_root>`) and `state check --file <state.yml> --step specify`
   per `gates.md`. Set `step=specify` when it was `start`.
2. **Draft to disk first.** Copy `./templates/spec.md` to `<spec_root>/<feature>/spec.md`
   (draft marker on line 1) and fill what the brief already answers: problem, scope, out of
   scope, acceptance criteria, open questions (start with the brief's "Not said" list),
   provenance. Every AC follows the forms in `interview.md`; an AC that cannot be checked is
   an open question, not an AC. A fix feature's AC1 is its reproduction (`lite.md`).
3. **Interview** per `interview.md`: at most three rounds (one on quick) of at most four
   grouped questions, aimed at the open questions and at ACs that are still vague. Write
   each answer into the file as it arrives. "Don't know" becomes an open question with an
   owner and stays.
4. **Re-triage** (quick only) per `lite.md`: a design signal or more than five tasks means
   one question, escalate to full (`state escalate`) or stay quick. Escalated: continue
   from step 3 as full.
5. **Critic** per `critic.md` when `flow.critic` and the tier say so: dispatch `critic` at
   `models.judgment` with `spec.md` and `project.md`, fold its findings into `## Open
   questions` as `critic C<k>` lines, say how many. Otherwise one line saying why not.
6. **Tasks** (quick only) per `lite.md`: draft `tasks.md` from the tasks template and
   breakdown rules, at most five tasks plus Verify, matrix with Test filled.
7. **G1** per `gates.md`: path plus at most ten lines (problem in one line, scope and out of
   scope, AC count with the weakest AC named, open questions with owners; quick: the task
   list). Approve: remove the marker(s), `state set gates.G1=now step=next` (quick: plus
   `gates.G3=now tasks.T1=todo …` in the same call), clear later gates when re-running,
   commit `spec(<feature>): specify` with every file written.
8. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Review`: the open questions
   (critic ones first) and any AC the user accepted as manual; on quick, a declined
   escalation. `Next: /specd:<step> <feature>` with the step `state set` reported.

## Anti-patterns

- Writing the spec only at the end of the interview; the draft is on disk before question one.
- Restating the brief as the spec. The spec is the agreement, the brief is the ask.
- Acceptance criteria with "should", "properly", "fast" or "user-friendly" in them.
- Deciding architecture here (tables, endpoints, libraries); that is `design`.
- More than three rounds. Leftovers are open questions with owners, not more questions.
- Resolving a critic finding yourself, or dropping one; they are the user's at the gate.
- Drafting tasks on full, or a sixth task on quick instead of proposing escalation.
