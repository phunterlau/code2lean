"""Diff-test cases for list_unique."""

FUNCTION = "list_unique"

CASES = [
    (([],), "listUnique []"),
    (([1],), "listUnique [1]"),
    (([1, 1, 1],), "listUnique [1, 1, 1]"),
    (([1, 2, 1, 3, 2],), "listUnique [1, 2, 1, 3, 2]"),
    (([0, 1, 0, 2],), "listUnique [0, 1, 0, 2]"),
]
