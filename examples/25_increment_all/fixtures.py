"""Diff-test cases for increment_all."""

FUNCTION = "increment_all"

CASES = [
    (([],), "incrementAll []"),
    (([0],), "incrementAll [0]"),
    (([1, 2, 3],), "incrementAll [1, 2, 3]"),
    (([9, 0, 9],), "incrementAll [9, 0, 9]"),
    (([5, 5, 5],), "incrementAll [5, 5, 5]"),
]
