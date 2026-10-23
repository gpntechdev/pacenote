# Runtime checks

Read by `runtime-verify` steps 3 to 8. How an acceptance criterion becomes something to run
against the started app, the plan file the script takes, the browser prompt, and what is
written back.

## Classify each AC

Read the AC text in `spec.md` and, when present, `design.md` `## API and contracts`
(external calls, changed contracts) and `## UX flows` (screens, states). One kind per AC:

| Kind | When | Runs as |
|---|---|---|
| `http` | the AC names a request and a response: an endpoint, a status, a body field, a header, an error for a bad input | a row in the plan file, run by `runtime-check run` |
| `browser` | the AC names what a person sees or does in a page: a screen, a button, a message, a form, a redirect after an action | steps for the `runtime-verifier` agent |
| `none` | the AC is internal (a function's return, a migration, a log line, a config default), a performance number, or needs data the app cannot be given from outside | not run; verify's evidence stands. Say why in one clause |

An AC that names both (an API and the page using it) is `browser` when a person is the
subject, `http` otherwise. Do not invent an endpoint or a screen: a path or label the spec,
the design or the code does not name is looked up in `<code_root>` (routes, page titles)
with Grep before it is planned, and an AC whose target cannot be found is `none` with
"target not found".

## The proposal table

```
| AC | Kind | What runs | Must see |
|---|---|---|---|
| AC1 | http | GET /items | 200, JSON list with `name` |
| AC3 | browser | / → fill Name "tea" → click Add | "tea" in the list |
| AC4 | none | internal: cache TTL | — |
```

## Plan file (`http` rows)

Written with the Write tool to `<workspace_root>/.runtime/plan.json` (the folder exists
after `start`; never through a heredoc), one object per check, ids `R1..`:

```json
[
  {"id": "R1", "ac": "AC1", "method": "GET", "path": "/items",
   "expect": {"status": 200, "json": [{"name": "tea"}]}},
  {"id": "R2", "ac": "AC2", "method": "POST", "path": "/items", "json": {"name": ""},
   "expect": {"status": 422, "contains": ["name required"]}},
  {"id": "R3", "ac": "AC5", "method": "GET", "path": "/health",
   "expect": {"status": 200, "header": {"content-type": "json"}}}
]
```

- `path` starts with one `/`; the script refuses anything else, so no request leaves the
  app's origin. Query strings go in `path`.
- `json` (sent with `Content-Type: application/json`) or `body`, never both. `headers` only
  for what the AC needs (an auth header the user gave for a test account; never a real
  credential from a file).
- `expect` holds only what the AC states: `status`, `contains` (substrings), `json` (subset
  of the parsed body; a list must match in length), `header` (name → substring).
- Order matters when one check creates what the next reads; the script runs them in order.
- An AC may need several rows (happy path and error path); each carries the AC id.

## Browser prompt (`browser` rows)

Dispatch `runtime-verifier` once for all browser rows, model `models.execution`, with:

```
Base URL: <serve_url>
Exercise each AC below in order and answer in your Answer shape.
- AC<n>: start at <path>. Steps: <step>; <step>; ... Must see: <text or state>.
```

Steps use the visible names the page shows (button labels, field labels), taken from the
spec, the design's UX flows or the code. Never pass file contents, credentials or the
plan file.

## Writing back

- `runtime.md` from `../templates/runtime.md`, replaced whole on every run: header (date,
  URL, command or "already running"), one section per AC that ran, then the skipped ones in
  one line each. Excerpts are the script's (already redacted, at most 400 characters);
  browser rows quote the agent's `saw`. At most 150 lines: past that, keep one excerpt per
  AC.
- Matrix Evidence cell of a passed AC: append `; runtime: <what ran> → <what was seen>
  (<YYYY-MM-DD>)` to what verify wrote, e.g. `; runtime: POST /items → 201 {"name":"milk"}
  (2026-10-23)` or `; runtime: browser / → Add "tea" → saw "tea" (2026-10-23)`. A re-run
  replaces an earlier `runtime:` part instead of appending a second.
- A failed or blocked AC: the step's question offers a fix task or acceptance (spine
  step 8); an accepted one gets `; runtime: failed, accepted: <reason> (<date>)`.
- `none` and skipped ACs: cell unchanged.
