# Distilling a kept folder

How `spec-clean` step 6 writes a feature record for an old kept folder that never got one.
The rules are `docs`' ([`../../docs/references/distill.md`](../../docs/references/distill.md))
and the template is [`../../docs/templates/feature.md`](../../docs/templates/feature.md); this
file states only what differs when the feature shipped weeks ago and its branch is gone.

## Sources

- `spec.md`, `design.md` (the sections it has), `tasks.md`, `review.md` and `state.yml` of
  the folder, read one folder at a time. No `git diff`: the branch is merged or deleted.
- The current tree under `<code_root>` instead of the diff stat: Glob each path the design's
  Changes by area (quick: `tasks.md` files lines) names.

## Differences from `docs`

- `Shipped:` the date of `updated` in `state.yml` (when it was closed). `PR:` the `pr` value,
  or `unknown` when empty; never `pending`, nothing is pending any more.
- `Where it lives`: only paths that still exist. A planned path that is gone is left out and
  counted in one Notes line: `<n> planned paths no longer exist; the feature may have moved`.
  When none exists, the record says so in Notes and the table is omitted.
- `How to verify`: test names from `tasks.md` whose file still exists; drop the rest.
- No architecture or data-model deltas: the code has moved on since, and a patch from an old
  design would state stale facts. One Notes line instead: `Architecture and data models not
  updated from this record; /specd:onboard architecture refreshes them.`
- Decisions: the `### D<n>` blocks were already judged in the proposal (step 3) by the
  durability test; write only the approved ones, numbered after the highest existing file,
  dated today, with `Consequences` drafted from `review.md` and the record's Notes. A title
  already in `decisions/README.md` is not written again.
- The README row in `features/README.md` (created from
  [`../../docs/templates/features-README.md`](../../docs/templates/features-README.md) when
  missing) uses the `Shipped` date above; rows stay in date order, so it is inserted by date,
  not appended.

## Rules kept from `docs`

No AC ids or evidence in the record; diagrams copied verbatim with `· AC<n>` stripped; at most
150 lines for the record and 40 for a decision; no draft markers, the approval is the sign-off.
