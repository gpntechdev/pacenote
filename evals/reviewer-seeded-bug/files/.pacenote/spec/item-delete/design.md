# Design: item-delete

## Approach
A deleted slot becomes `None` so ids never shift; `get` returns that `None`.

## Changes by area
- `items.py`: `delete`.
- `tests/test_items.py`: delete cases.
