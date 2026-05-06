"""Diff-test cases for list_count_pos."""

FUNCTION = "list_count_pos"

CASES = [
    (([],), "listCountPos []"),
    (([0],), "listCountPos [0]"),
    (([1],), "listCountPos [1]"),
    (([0, 1, 2, 0],), "listCountPos [0, 1, 2, 0]"),
    (([3, 2, 1],), "listCountPos [3, 2, 1]"),
]
