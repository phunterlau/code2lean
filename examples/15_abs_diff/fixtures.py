"""Diff-test cases for abs_diff."""

FUNCTION = "abs_diff"

CASES = [
    ((0, 0), "absDiff 0 0"),
    ((5, 0), "absDiff 5 0"),
    ((0, 5), "absDiff 0 5"),
    ((9, 4), "absDiff 9 4"),
    ((4, 9), "absDiff 4 9"),
    ((42, 42), "absDiff 42 42"),
]
