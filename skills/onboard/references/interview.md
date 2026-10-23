# Interviews

Two uses: the whole section in greenfield (no code to scan), and the gap interview in either
kind (checklist items still UNKNOWN after the scan). Both use the assistant's question tool with
concrete options when one exists; otherwise ask in prose, one topic at a time.

## Rules for every interview

- Ask only what the checklist needs and what neither code, docs nor pasted sources answered.
- Group questions: at most four per round, each about one checklist item, defaults prefilled
  from what is already known. Two rounds per section is the norm; three is the cap. Beyond
  that, write the draft with the gaps marked `TODO(onboard)` and move to sign-off.
- When the user points at a source ("it is in the Confluence page", "here is the RFC"), take
  it: snapshot it per [`sources.md`](../../_shared/sources.md) and read that instead of asking further.
- Record answers in the draft as you go, not at the end. The draft on disk is the state.
- "I don't know" is an answer: write `unknown as of <date>` in the file and move on.

## Greenfield: project section (the idea interview)

Round 1: what it is (two sentences), who uses it, the one outcome that makes it worth building.
Round 2: constraints (deadline, budget, platforms, compliance), preferences already fixed
(language, hosting, existing accounts), and the must / should / won't split for the first
version. Write `project.md` with `## Run, test, lint` left as "filled by /pacenote:scaffold".

## Greenfield: architecture section

Round 1: stack (language, framework, package manager, versions if known) and the structure
preference (single app, monorepo, service split). Round 2: tooling per line of A4 and the
testing strategy (A5). Round 3, only if the user asks "what is recommended": dispatch
`researcher` with one question per topic (at most three), the constraints already chosen, and
the `judgment` model role; present the findings as options, let the user pick, and write the
pick plus its reason into `## Key decisions`. Each decision with a lasting consequence also
becomes a file in `decisions/` (use `../../_shared/templates/decision.md`); reference it, do not repeat it.

`scaffold` reads the first four headings of `overview.md` verbatim, so `## Stack`, `## Structure`,
`## Tooling` and `## Testing strategy` must be concrete: names and commands, not intentions.

## Greenfield: conventions, data-models, decisions

Conventions: offer the stack's mainstream defaults (formatter, linter, test layout, commit
convention from `pacenote.yml`) as prefilled answers; the user edits. Data models: ask D1; if yes,
one round on domains and entities, one file per domain with key fields and defaults, since
no code exists to point at; once it does, `onboard data-models` refreshes the files to
pointers. Decisions: usually already written during architecture; the section confirms the
index and adds anything the user names.

## Brownfield: the gap interview

The scan answers what code can tell. What it cannot: the domain in the users' words (P1, P2),
who decides and where truth lives (P7), team rules that are habit rather than tooling (C2, C5,
C6), the reasons behind visible choices (A6, R2). Ask those; never re-ask what the explorer
answered with a pointer. When the user contradicts the scan, the user wins; note the pointer
so the contradiction is visible in the draft.
