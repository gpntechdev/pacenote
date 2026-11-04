# item-rename

Items can be renamed in place with `items.rename(item_id, name)`. An empty name is refused
with `ValueError` and the old name stays; an id that was never added raises `KeyError`.

Where it lives: `items.py` (`rename`), tests in `tests/test_items.py`.
