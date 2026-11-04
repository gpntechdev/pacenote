# item-delete: delete an item

## Problem
Items can be added but never removed.

## Scope
- `delete(item_id)` in `items.py`; ids are never reused.

## Out of scope
- Undo.

## Acceptance criteria
- AC1: `delete(id)` removes that item; `get(id)` then returns None and other items are unchanged.
- AC2: `delete` of a missing or already deleted id raises `KeyError`.

## Open questions
- none
