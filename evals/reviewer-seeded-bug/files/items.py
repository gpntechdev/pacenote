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
        return _items[item_id - 1]  # None once deleted
    return None


def delete(item_id):
    """Remove the item with this id; a missing id raises KeyError."""
    if not 1 <= item_id <= len(_items) or _items[item_id - 1] is None:
        raise KeyError(item_id)
    _items[item_id] = None


def reset():
    _items.clear()
