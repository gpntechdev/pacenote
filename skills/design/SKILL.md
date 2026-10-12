---
name: design
description: >
  Invoke whenever the user asks to design, architect or plan how a specified feature will be
  built, or runs `/specd:design [feature]`; also as the next step after `/specd:specify`. It
  decides which design sections the feature needs from the spec's signals, has the architect
  agent draft `design.md` from the spec, the project docs and the code, walks you through its
  decisions and open questions, asks you to approve it (G2) and commits. Not for writing
  requirements (`/specd:specify`) or for breaking work into tasks (`/specd:tasks`).
---

# Skill: design

Produces one `design.md` with only the sections the feature needs. The main thread selects
the sections and interviews; the `architect` agent does the reading and drafting in its own
context, so the design is grounded in the code without the code filling this conversation.

## Gate

G1 approved (`state check --step design`; full tier only, quick escalates when a design
signal fires). `rerun: true` clears G2..G5 on write; ask first.

## Inputs

- `resolve-paths`, `detect-repo`, `state find`, `state check`.
- `<spec_root>/<feature>/spec.md`, `brief.md`, `state.yml` (tier).
- `<docs_root>/project.md`, `architecture/overview.md` and the area files it names,
  `conventions.md`, `data-models/` when present.
- `<workspace_root>/specd.yml`: `models.judgment`, `flow.critic`, `git.authority`.
- [`../_shared/paths.md`](../_shared/paths.md), [`../_shared/gates.md`](../_shared/gates.md), [`../_shared/state-yml.md`](../_shared/state-yml.md),
  [`../_shared/critic.md`](../_shared/critic.md).
- [`./references/sections.md`](./references/sections.md),
  [`./references/architect-prompt.md`](./references/architect-prompt.md), `./templates/design.md`.

## Outputs

- `<spec_root>/<feature>/design.md`; `gates.G2`, `step: tasks` in `state.yml`.
- One commit `spec(<feature>): design` (authority ≠ `none`).

## Protocol

1. **Resolve** per `paths.md` ("Resolving for a feature"), `state check --step design`
   per `gates.md`. Set `step=design`.
2. **Select sections.** Read `spec.md` and apply the signal table in `sections.md`. Approach
   and decisions are always in. Show the selection in at most six lines, each section with
   the AC or sentence that triggered it, and ask the user to add or remove. Sections nobody
   asked for are not written.
3. **Draft.** Dispatch `architect` at `models.judgment` with `architect-prompt.md` filled:
   absolute paths of every input, the skip globs, the chosen sections, the template quoted,
   and `<spec_root>/<feature>/design.md` as the only writable path. It writes the draft with
   the marker on line 1.
4. **Interview.** Show the agent's summary as it came back (never the file). Walk the open
   questions and each proposed decision with the user: keep / change / drop, at most four per
   round, three rounds. Edit `design.md` in place as answers arrive; a dropped decision is
   removed, a changed one keeps its alternatives list. Leftovers go to `## Risks` as open
   items with an owner.
5. **Critic** per `critic.md` when `flow.critic` is not `off`: dispatch `critic` at
   `models.judgment` with `design.md`, `spec.md` and `project.md`, fold its findings into
   `## Risks` as `critic C<k>` lines, say how many. Otherwise one line: `critic: off`.
6. **G2** per `gates.md`: path plus at most ten lines (approach in one line, decisions by
   title, sections included, open risks). Approve: remove the marker, `state set gates.G2=now
   step=tasks`, clear G3..G5 when re-running, commit `spec(<feature>): design`.
7. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Review`: the decisions
   that could go another way. `Next: /specd:tasks <feature>`.

## Anti-patterns

- Reading the codebase in the main thread; the architect's pointers are the evidence.
- Writing sections the signal table did not select "for completeness".
- A decision without alternatives, or an alternative without the reason it lost.
- Introducing a library or service the project does not already use without an open question.
- Approving G2 with open questions that block a task; they are risks with owners or they
  are answered.
