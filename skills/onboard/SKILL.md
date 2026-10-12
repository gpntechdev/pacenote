---
name: onboard
description: >
  Invoke whenever the user asks to onboard, document, describe or map the project for the
  workflow, fill or refresh the project docs, or run `/specd:onboard [section]`; also as the
  next step after `/specd:init`. It fills `<docs_root>/` one section per context (project,
  architecture, conventions, data-models, decisions) from a codebase scan or an interview plus
  gap questions, writes each section to disk and commits it after sign-off, and resumes from
  the first unfinished section after `/clear`. Not for writing feature specs.
---

# Skill: onboard

Fills the persistent knowledge in `<docs_root>/`, one section at a time, so that later steps
read facts instead of guessing. Brownfield sections come from an `explorer` scan; greenfield
sections from an interview. Either way the main thread holds only summaries and answers.

## Inputs

- `"${CLAUDE_PLUGIN_ROOT}/scripts/resolve-paths"` output (roots; see
  [`../_shared/paths.md`](../_shared/paths.md)).
- `"${CLAUDE_PLUGIN_ROOT}/scripts/detect-repo"` output: kind, existing docs.
- `<workspace_root>/specd.yml`: `models.cheap`, `models.judgment`, `project`.
- [`./references/checklist.md`](./references/checklist.md): what each section must answer.
- Existing `CLAUDE.md`, `AGENTS.md`, `README`, docs folders: read, never rewritten.
- Section files already in `<docs_root>/` (when refreshing or resuming).

## Outputs

| Section | Template | Target |
|---|---|---|
| project | `./templates/project.md` | `<docs_root>/project.md` |
| architecture | `./templates/architecture-overview.md`, `architecture-area.md` | `<docs_root>/architecture/overview.md`, `<area>.md` |
| conventions | `./templates/conventions.md` | `<docs_root>/conventions.md` |
| data-models | `./templates/data-models-README.md`, `data-model.md` | `<docs_root>/data-models/README.md`, `<domain>.md` |
| decisions | `./templates/decisions-README.md`, `../_shared/templates/decision.md` | `<docs_root>/decisions/README.md`, `NNNN-<title>.md` |

Plus `<workspace_root>/sources/<slug>.md` for pasted or fetched pages, and one commit per
signed-off section.

## Protocol

1. **Resolve.** Run `resolve-paths`. No config: say `run /specd:init first` and stop. Run
   `detect-repo --from <code_root>`; state the kind in one line ("brownfield: 412 source files"). The user may
   override it in the same turn.
2. **Pick the section.** With an argument, that section; its existing files are inputs and are
   re-drafted. Without one, the first in the order project, architecture, conventions,
   data-models, decisions whose index file (the first target in the table) is missing, or
   any of whose files still starts with `<!-- specd:draft -->`. None left: say "onboard
   complete" and go to step 7.
3. **Gather.** Brownfield: dispatch one `explorer` run with the section's prompt from
   [`./references/scan-prompts.md`](./references/scan-prompts.md), absolute paths filled in,
   model from `models.cheap`. For architecture and data-models the first run is a map pass
   (areas or domains with folder and count, no detail); more than five items means this run
   writes the index plus one draft stub per item and stops after the index is signed off;
   every later run fills up to five stubs, one explorer item pass each, and signs those off.
   Five or fewer: index and items in one run. Greenfield: run the section's interview from
   [`./references/interview.md`](./references/interview.md); the architecture section may
   dispatch `researcher` at `models.judgment`. In both kinds, when the user pastes or names a
   page, snapshot it per [`../_shared/sources.md`](../_shared/sources.md) and read the
   snapshot.
4. **Draft to disk first.** Copy the section's template(s) to their targets now, with the
   draft marker as line 1; fill from the gathered material; cite `path:line` and
   `sources/<slug>.md`; link existing docs instead of copying them. In brownfield, a target
   that already exists as a human-written doc is linked from the draft, never overwritten
   (write the draft next to it as `<name>.specd.md` and say so).
5. **Gap interview.** For checklist items still UNKNOWN, ask per the rules in `interview.md`:
   grouped, at most four per round, three rounds. Write each answer into the draft as it
   arrives. Leave unresolved items as `TODO(onboard)`.
6. **Sign-off.** Show the target paths and a summary of at most ten lines: what was found,
   what was assumed, what is still TODO. Ask approve / edit / reject. Edit: apply and re-show.
   Reject: leave the draft on disk with its marker, go to step 7. Approve: remove the marker
   line from every file drafted in this run (stubs not filled keep theirs), then commit
   `docs: onboard <section>` (`docs: onboard <section> <items>` for a batch) in the repo
   that contains `docs_root`, no attribution (see
   [`../_shared/no-attribution.md`](../_shared/no-attribution.md)).
7. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Next`: the next unfinished
   section as `/specd:onboard`, or when all are signed off, `/specd:scaffold` in greenfield;
   in brownfield, `/specd:start <feature>`. Mention that
   `/specd:toolsmith` (project skills, MCP recommendations) comes later.

Each run covers one section, or one batch of a large section, then stops. The user runs
`/clear` and the command again; step 2 finds where to continue from the draft markers.

## Anti-patterns

- Reading source files in the main thread. Everything a section needs comes back from
  `explorer` as pointers, or from the user.
- Writing a section only at the end. The draft goes to disk before the first question.
- Overwriting a doc the team wrote. Link it; put specd's view next to it.
- Answering a checklist item from general knowledge of the stack instead of this repo.
- Padding `project.md` or `conventions.md` past their caps; they load every session.
- Copying fields or schemas into a brownfield data-model file; the code is the schema, the
  file holds pointers, relationships and invariants.
