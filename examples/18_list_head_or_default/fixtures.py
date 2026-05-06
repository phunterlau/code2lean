"""Diff-test cases for list_head_or_default."""

FUNCTION = "list_head_or_default"

CASES = [
    (([],), "listHeadOrDefault []"),
    (([0],), "listHeadOrDefault [0]"),
    (([7],), "listHeadOrDefault [7]"),
    (([1, 2, 3],), "listHeadOrDefault [1, 2, 3]"),
    (([9, 0, 9],), "listHeadOrDefault [9, 0, 9]"),
]
