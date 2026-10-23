---
name: research
description: >
  Invoke first, before any web search or fetch, whenever the user asks to research, look
  up or check an external fact (the current recommended way to do X in a library, which
  versions are supported, whether an API is deprecated, a documented limit), asks "what do
  the docs say about", or runs `/pacenote:research "<question>" [--feature <name>]`. It sends
  each question (at most three) to the `researcher` agent at the judgment role, Context7
  first, and prints its cited findings with the date each source was seen. Then it asks
  where the answer goes: a section in the active feature's `research.md`, a dated note
  under `<docs_root>/research/`, or nowhere, and commits once, never on a default branch.
  The main thread never fetches a page itself. Not for questions about this codebase (that
  is an explorer scan) or for taking in a ticket or page as a feature source (that is
  `/pacenote:start --from`).
---

# Skill: research

Answers a factual question from outside the repo with sources, and keeps the answer only
where the user wants it. The `researcher` agent does every search and fetch in its own
context and returns findings with URLs and dates; the main thread prints them, asks once and
writes. A util per [`../_shared/utils.md`](../_shared/utils.md): no `state check`, nothing
written without a yes. The dispatch and both write formats are in
[`../_shared/research.md`](../_shared/research.md).

## Inputs

- The argument: the question (several are split, at most three), optionally `--feature
  <name>`.
- `resolve-paths` and, softly, `state find` ([`../_shared/paths.md`](../_shared/paths.md)):
  a refusal, an ambiguity or a closed feature means no feature, not a stop.
  `detect-repo --from <root>` for the repo that will change.
- `<workspace_root>/pacenote.yml`: `models.judgment`, `git.authority`.
- `<docs_root>/project.md`: the stack and versions line, for the constraints.
- `<docs_root>/research/README.md`, to check whether the question was asked before and to
  add a row; the feature's `research.md` when appending to it.

## Outputs

- The findings, printed.
- On the user's choice, one of:
  - a section appended to `<spec_root>/<feature>/research.md`, committed as
    `spec(research): attach <n>` with `git -C <workspace_root>`;
  - `<docs_root>/research/<YYYY-MM-DD>-<slug>.md` and its row in `research/README.md`,
    committed as `docs(research): note <n>` with `git -C <docs_root>`;
  - nothing.
- No commit when nothing was written or `git.authority` is `none`.

## Protocol

1. **Resolve.** `resolve-paths` (no config: `run /pacenote:init first`). `state find
   --spec-root <spec_root> --worktrees <wrapper_root>/.worktrees [--feature <name>]`; keep
   the feature only when it resolves to one whose `step` is not `closed`. A named
   `--feature` that does not resolve: say so in one line and go on without it.
2. **Frame.** Turn the argument into at most three one-sentence questions; more: ask which
   three. A question about this codebase is not researched: say it is an explorer scan
   (`/pacenote:onboard`, or the feature's own steps) and drop it. When `research/README.md`
   already has a row for the same question, name that note and its date in one line, then
   go on: a newer answer is a new note.
3. **Dispatch** `researcher` per `research.md` "Dispatch", one per question, in parallel,
   at `models.judgment`, with the stack line from `project.md` and any constraint the user
   gave. Never search or fetch in the main thread, not even to check a URL.
4. **Print** each answer under its question, as returned. An agent that hit its turn limit
   or returned no URL for a claim: say so; do not fill the gap.
5. **Ask** one question, naming the branch the write would go to (per `utils.md`
   "Branch"): attach to `<feature>` (only when step 1 kept one), save a docs note, or don't
   save. With several questions the choice covers all of them; "adjust" takes per-question
   choices in free text.
6. **Branch** per `utils.md` "Branch", for the repo holding the chosen root
   (`<workspace_root>` for attach, `<docs_root>` for a note). Don't save: skip to step 9.
7. **Write** per `research.md` "Where it is written": the feature sections in question
   order; or one note per question from [`./templates/note.md`](./templates/note.md)
   (without its comment), plus one row each in `research/README.md`, created from
   [`./templates/research-README.md`](./templates/research-README.md) (without its
   comment) when missing.
8. **Commit** per `utils.md`: add the written files by name; `spec(research): attach <n>`
   or `docs(research): note <n>`, `<n>` the questions written.
9. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced`: the
   written files, or none. `Review`: findings marked low confidence, anything under Not
   found, sources that disagree, and the branch to push. `State: research`. `Next`: the
   command the user was running, or `none`.

## Anti-patterns

- WebSearch, WebFetch or a Context7 call in the main thread; the agent is the only reader of
  fetched pages.
- Rewording, merging or extending the findings; a claim without the agent's URL is a guess.
- Turning a finding into a decision, a code change or an edit to `spec.md` or `design.md`;
  the user decides, in the step that owns the file.
- Writing or committing before the choice in step 5.
- Researching what the codebase or `<docs_root>` already answers.
