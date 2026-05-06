"""Diff-test cases for bounded_sub."""

FUNCTION = "bounded_sub"

CASES = [
    ((0, 0), "boundedSub 0 0"),
    ((5, 0), "boundedSub 5 0"),
    ((0, 5), "boundedSub 0 5"),
    ((9, 4), "boundedSub 9 4"),
    ((4, 9), "boundedSub 4 9"),
    ((42, 42), "boundedSub 42 42"),
]
