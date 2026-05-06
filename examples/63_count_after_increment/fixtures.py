"""Diff-test cases for count_after_increment."""

FUNCTION = "count_after_increment"

CASES = [
    (([],), "countAfterIncrement []"),
    (([0],), "countAfterIncrement [0]"),
    (([1, 2, 3],), "countAfterIncrement [1, 2, 3]"),
    (([0, 1, 0],), "countAfterIncrement [0, 1, 0]"),
    (([5, 0, 7],), "countAfterIncrement [5, 0, 7]"),
]
