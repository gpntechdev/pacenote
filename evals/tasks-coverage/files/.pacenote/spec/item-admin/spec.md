# item-admin: rename, delete and list items

## Problem
The store can add and get items but cannot change, remove or list them.

## Scope
- `rename(item_id, name)`, `delete(item_id)` and `list_items()` in `items.py`.

## Out of scope
- Persistence; the store stays in memory.

## Acceptance criteria
- AC1: `rename(id, name)` changes the item's name; `get(id)` returns the new name.
- AC2: `rename` with an empty name raises `ValueError` and leaves the item unchanged.
- AC3: `delete(id)` removes the item; `get(id)` then returns None.
- AC4: `delete` or `rename` of a missing id raises `KeyError`.
- AC5: `list_items()` returns every item as `(id, name, price)`, ordered by id.

## Open questions
- none
