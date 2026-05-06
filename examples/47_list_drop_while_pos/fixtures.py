"""Diff-test cases for list_drop_while_pos."""

FUNCTION = "list_drop_while_pos"

CASES = [
    (([],), "listDropWhilePos []"),
    (([0],), "listDropWhilePos [0]"),
    (([1, 2, 0, 3],), "listDropWhilePos [1, 2, 0, 3]"),
    (([5, 4, 3],), "listDropWhilePos [5, 4, 3]"),
    (([0, 1, 2],), "listDropWhilePos [0, 1, 2]"),
]
