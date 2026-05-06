"""Diff-test cases for list_filter_even."""

FUNCTION = "list_filter_even"

CASES = [
    (([],), "listFilterEven []"),
    (([1],), "listFilterEven [1]"),
    (([2],), "listFilterEven [2]"),
    (([1, 2, 3, 4],), "listFilterEven [1, 2, 3, 4]"),
    (([0, 2, 4, 6],), "listFilterEven [0, 2, 4, 6]"),
]
