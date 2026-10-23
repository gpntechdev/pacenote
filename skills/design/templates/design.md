<!-- pacenote:draft -->
<!-- Written by the architect agent for /pacenote:design to <spec_root>/<feature>/design.md; read
     by tasks, implement, review and close. Only the sections listed on the Sections line
     exist; Approach and Decisions always. Sub-headings are fixed: tasks reads "Changes by
     area" and the contract kinds by name; empty kinds are omitted, not left blank.
     Signatures and shapes go in code fences, behaviour in one line of prose each. Each
     decision is `### D<n>: <title>` with Context, Decision, Alternatives, Consequences so
     close can turn it into a decision file. At most 250 lines. Remove the first line on G2. -->
# Design: {{feature}}

Sections: Approach, Decisions{{, Data model, API and contracts, Sequences, UX flows}} · Spec: `spec.md`

## Approach

### Summary

<!-- At most three sentences, no pointers: what is built and the pattern it follows. -->

### Builds on

<!-- Existing code and docs reused or extended, one bullet each: `path:line` — what it gives us. -->

### Changes by area

| Area | Files | Change |
|---|---|---|
| {{area}} | `{{path}}`, `{{path}}` | {{one clause}} |

## Decisions

<!-- One block per real decision (had alternatives). Facts and conventions are not decisions.
     Each field at most three lines. -->

### D1: {{title}}

Context:
Decision:
Alternatives: {{a}} (rejected because …); {{b}} (…)
Consequences:

## Data model

<!-- Only when selected. -->

### Entities

<!-- Table: Entity | Change (new, field added, …) | Fields and constraints | Pointer. -->

### Migration

<!-- Steps in order; what existing data does. Link data-models/<domain>.md. -->

## API and contracts

<!-- Only when selected. Keep the kinds present; drop the rest. -->

### External calls

| Call | Request | Response | Errors |
|---|---|---|---|
| {{METHOD path}} | {{params, headers}} | {{shape or type name}} | {{status -> error}} |

### Types

```ts
// shapes and enums introduced or changed; one fence, grouped by file
```

### Module interfaces

<!-- One fenced signature per function, composable, hook or service, followed by one line of
     behaviour: what it returns, when it throws, what it caches. -->

```ts
{{signature}}
```
{{one line of behaviour}}

### Components

| Component | Props | Emits | Notes |
|---|---|---|---|
| {{Name}} | `{{prop: type}}` | `{{event: payload}}` | {{states it renders}} |

### Changed contracts

| Contract | Before | After |
|---|---|---|
| {{name}} | {{old}} | {{new}} |

## Sequences

<!-- Only when selected. One Mermaid sequenceDiagram per flow with more than one actor or an
     async hop; happy path and the error branch that matters. A one-line title above each. -->

## UX flows

<!-- Only when selected. Screens or states as a Mermaid flowchart or a list; the state
     machine when there is one; which AC each screen serves. -->

## Risks

<!-- What could go wrong and what limits it; open items as `owner: <who>`. "none" if none. -->
