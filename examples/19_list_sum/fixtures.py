"""Diff-test cases for list_sum."""

FUNCTION = "list_sum"

CASES = [
    (([],), "listSum []"),
    (([0],), "listSum [0]"),
    (([1, 2, 3],), "listSum [1, 2, 3]"),
    (([5, 5, 5],), "listSum [5, 5, 5]"),
    (([10, 0, 1],), "listSum [10, 0, 1]"),
    (([9, 8, 7, 6],), "listSum [9, 8, 7, 6]"),
]
