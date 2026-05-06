"""Diff-test cases for list_min."""

FUNCTION = "list_min"

CASES = [
    (([],), "listMin []"),
    (([0],), "listMin [0]"),
    (([1, 2, 3],), "listMin [1, 2, 3]"),
    (([3, 2, 1],), "listMin [3, 2, 1]"),
    (([4, 9, 2, 9],), "listMin [4, 9, 2, 9]"),
]
