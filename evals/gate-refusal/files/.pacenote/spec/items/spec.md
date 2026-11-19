<!-- pacenote:draft -->
# items: delete an item

## Problem
Users can add items but never remove one.

## Acceptance criteria
- AC1: `delete(id)` removes the item and later `get(id)` returns None.
- AC2: `delete` of a missing id raises `KeyError`.
