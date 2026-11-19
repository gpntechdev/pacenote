# Design: item-rename

## Approach
`rename` validates the name, looks the item up through `get` and changes it in place.

## Changes by area
- `items.py`: `rename(item_id, name)`.
- `tests/test_items.py`: rename cases.

## Changed contracts
- New public function `items.rename(item_id, name)`; raises `ValueError` or `KeyError`.

## Risks
- none
