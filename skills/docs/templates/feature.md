<!-- Written by /pacenote:docs to <docs_root>/features/<feature>.md before the PR opens; refreshed
     after a feedback cycle; read by later features, by fix and by onboard refreshes. Two
     readers: a person who wants to know what the feature is, and an agent about to change it.
     Only the sections the sources have are written: User flow and How it works need the UX
     flows and Sequences of design.md, Interfaces its API and contracts or Data model; a
     section without a source is omitted, not left empty. At most 150 lines, diagrams
     included; close removes the spec folder, git history holds the rest. -->
# Feature: {{feature}}

Shipped: {{date}} · PR: {{url or pending}} · Tier: {{tier}}

## What it does

<!-- Two to four sentences from spec.md: the problem and the behaviour that solves it, as the
     user sees it. Then one line per entry point: the route, command, endpoint or UI element
     that leads here. -->

## User flow

<!-- The UX flows of design.md, verbatim (Mermaid flowchart or list), with `· AC<n>` stripped
     from the labels. -->

## Behaviour

<!-- The acceptance criteria as shipped, rewritten as short bullets under three to five
     sub-groups: Happy path, Errors and edge cases, Layout, or one group per screen. No AC
     ids, no evidence; a behaviour that changed after the spec is written as it shipped. -->

### Happy path

### Errors and edge cases

## How it works

<!-- The Approach summary of design.md in two or three sentences, then each Sequences block
     verbatim with its one-line title. -->

## Where it lives

<!-- One table, from design.md Changes by area trimmed to the diff. Roles in this order when
     present: entry (route, command, handler), view or screen, components, state and queries,
     api or service, domain or model, shared (reused by other features), config, tests. -->

| Role | Path | What is there |
|---|---|---|

## Interfaces

<!-- What another feature can call or must respect: exported functions, components and
     composables with a one-line signature each; external calls (method, path); cache keys or
     entities with their lifetime. From design.md API and contracts and Data model. At most
     ten lines. -->

## Decisions

<!-- `decisions/NNNN-<title>.md` — one line on what was decided; "none" if none. -->

## How to verify

<!-- The commands that prove it still works (test names, checks); manual steps if any. -->

## Notes

<!-- Known limits, accepted trade-offs, follow-ups, what is not verified against a live
     system. "none" if none. -->
