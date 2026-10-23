# Explorer prompt and report

One `explorer` dispatch per run at the `cheap` model role (read `models.cheap` from
`pacenote.yml` and pass it as the agent's model). Every path absolute. The agent gets the files
the script pointed at, never the conversation or the whole tree.

## Dispatch

```
Root: <code_root>. Read only these files: <the top five hotspot files>, <each file named
in a cycle's closing import lines>. Skip everything else, and any secret-looking file.
Topic: why these places are hard to change.
Checklist:
- For each hotspot <file> (<commits> commits, <lines> lines): what it owns, in one clause,
  and whether it mixes concerns (name them) — `path:line`.
- For each cycle <module A> <-> <module B>: which import closes it (<file>:<line> from the
  list) and what it pulls across, in one clause — `path:line`.
Answer in the fixed four-section shape from your instructions, at most 40 lines; leave
"Existing docs" as "none".
```

## Report

Printed by the main thread from the script's JSON and the explorer's Checklist answers:

```
Hotspots (since <since>)
| File | Commits | Lines | Owns |                         top 10, the explorer's clause for the top 5

Coupling
| Module | Files | Fan-in | Fan-out | Depends on |        modules with fan-in + fan-out > 0, top 10

Cycles
- <A> <-> <B> · <file>:<line> `<import>` · <explorer's clause>

Test gaps
| File | Lines | Commits |                               top 10, hotspots first

Not parsed: <ext> (<n> files), ...                       only when `unsupported` is non-empty
```

- Numbers are the script's, never the explorer's. A hotspot or cycle the explorer answered
  UNKNOWN keeps its row with `—`.
- Empty sections print `none`.
