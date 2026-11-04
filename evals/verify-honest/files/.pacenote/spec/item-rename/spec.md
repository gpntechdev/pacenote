# item-rename: rename an item

## Problem
A typo in an item name can only be fixed by adding a new item.

## Scope
- `rename(item_id, name)` in `items.py`.

## Acceptance criteria
- AC1: `rename(id, name)` changes the item's name.
- AC2: `rename` with an empty name raises `ValueError` and leaves the name unchanged.
- AC3: `get` of an id that was never added returns None.
- AC4: `rename` of a missing id raises `KeyError`.

## Open questions
- none
