"""A tiny in-memory item store."""

_items = []


def add(name, price):
    """Add an item and return its id (1-based)."""
    if not name:
        raise ValueError("name is required")
    if price < 0:
        raise ValueError("price must not be negative")
    _items.append({"name": name, "price": price})
    return len(_items)


def get(item_id):
    """Return the item with this id, or None."""
    if 1 <= item_id <= len(_items):
        return _items[item_id - 1]
    return None


def rename(item_id, name):
    """Rename the item with this id; an empty name raises ValueError, a missing id KeyError."""
    if not name:
        raise ValueError("name is required")
    item = get(item_id)
    if item is None:
        raise KeyError(item_id)
    item["name"] = name


def reset():
    _items.clear()
