"""Diff-test cases for max2."""

FUNCTION = "max2"

CASES = [
    ((0, 0), "max2 0 0"),
    ((1, 0), "max2 1 0"),
    ((0, 1), "max2 0 1"),
    ((7, 3), "max2 7 3"),
    ((3, 7), "max2 3 7"),
    ((42, 42), "max2 42 42"),
]
