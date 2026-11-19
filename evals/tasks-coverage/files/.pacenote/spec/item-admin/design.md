# Design: item-admin

## Approach
Keep the list-backed store. A deleted slot becomes `None` so ids never shift; `get` treats a
`None` slot as missing. `rename` and `delete` share one `_require(item_id)` helper that raises
`KeyError` for a missing or deleted id. `list_items` skips `None` slots.

## Decisions
- D1: ids are positions in the list and are never reused (no compaction).

## Changes by area
- `items.py`: `_require`, `rename`, `delete`, `list_items`; `get` skips deleted slots.
- `tests/test_items.py`: cases for AC1-AC5.

## Risks
- none
