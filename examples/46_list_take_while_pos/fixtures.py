"""Diff-test cases for list_take_while_pos."""

FUNCTION = "list_take_while_pos"

CASES = [
    (([],), "listTakeWhilePos []"),
    (([0],), "listTakeWhilePos [0]"),
    (([1, 2, 0, 3],), "listTakeWhilePos [1, 2, 0, 3]"),
    (([5, 4, 3],), "listTakeWhilePos [5, 4, 3]"),
    (([0, 1, 2],), "listTakeWhilePos [0, 1, 2]"),
]
