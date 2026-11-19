import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import items  # noqa: E402


class ItemsTest(unittest.TestCase):
    def setUp(self):
        items.reset()

    def test_add_returns_id(self):
        self.assertEqual(items.add("pen", 2), 1)

    def test_get_missing(self):
        self.assertIsNone(items.get(5))

    def test_rename_changes_name(self):
        items.add("pen", 2)
        items.rename(1, "pencil")
        self.assertEqual(items.get(1)["name"], "pencil")

    def test_rename_empty_raises(self):
        items.add("pen", 2)
        with self.assertRaises(ValueError):
            items.rename(1, "")
        self.assertEqual(items.get(1)["name"], "pen")

    def test_rename_missing_raises(self):
        with self.assertRaises(KeyError):
            items.rename(9, "pencil")


if __name__ == "__main__":
    unittest.main()
