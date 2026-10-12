# Needs: from the stack to a short list

Read by `toolsmith` step 2. A need is one piece of knowledge an implementer of one layer
should read before writing code there, phrased so a skill could meet it.

## Layers

- Take the layer names already in `specd.yml` `layers` first; they are the vocabulary
  `tasks` uses, so never rename one.
- Add layers from `<docs_root>/architecture/overview.md` (areas, stack table) and the
  detection output (`detect-repo` languages and manifests, `detect-commands` runner):
  `frontend`, `backend`, `mobile`, `data`, `infra`, `cli`, or the name the overview uses.
- One layer per deployable or per clearly separate part of the code. A small repo has one.
- No docs and no signal: ask for the layers in the same question as the needs.

## Needs per layer

At most three, from what the code and docs actually use, most valuable first:

| Signal | Typical need |
|---|---|
| UI framework (React, Vue, Svelte, SwiftUI…) | component and state conventions; UI design guidance |
| Test runner for the layer | how tests are written here: structure, fixtures, mocks |
| Web or API framework | module layout, request validation and error conventions |
| ORM or migration tool | schema change and migration conventions |
| Browser-facing code | accessibility and end-to-end testing practice |
| Infra as code, CI | the pipeline's and the IaC tool's conventions |

- Phrase a need as knowledge, not a product: "React component conventions", not
  "install react-skill".
- Drop a need when `skill-lock list` shows an entry for the same layer that covers it
  (by name or description), unless the user names it again.
- `<docs_root>/conventions.md` already answering a need in full is a reason to drop it:
  the implementer reads that file anyway.

## The question

Print one line per need, `layer · need`, numbered, then ask once: confirm all, edit the
list (add, remove, rename), or drop all. A run with nothing confirmed goes to the MCP step.
