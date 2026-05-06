"""Diff-test cases for list_max."""

FUNCTION = "list_max"

CASES = [
    (([],), "listMax []"),
    (([0],), "listMax [0]"),
    (([1, 2, 3],), "listMax [1, 2, 3]"),
    (([3, 2, 1],), "listMax [3, 2, 1]"),
    (([4, 9, 2, 9],), "listMax [4, 9, 2, 9]"),
]
