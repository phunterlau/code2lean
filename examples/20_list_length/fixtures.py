"""Diff-test cases for list_length."""

FUNCTION = "list_length"

CASES = [
    (([],), "listLength []"),
    (([1],), "listLength [1]"),
    (([1, 2],), "listLength [1, 2]"),
    (([5, 4, 3, 2, 1],), "listLength [5, 4, 3, 2, 1]"),
    (([0, 0, 0, 0],), "listLength [0, 0, 0, 0]"),
]
