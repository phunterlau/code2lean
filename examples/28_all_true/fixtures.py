"""Diff-test cases for all_true."""

FUNCTION = "all_true"

CASES = [
    (([],), "allTrue []"),
    (([False],), "allTrue [false]"),
    (([True],), "allTrue [true]"),
    (([True, True, True],), "allTrue [true, true, true]"),
    (([True, False, True],), "allTrue [true, false, true]"),
    (([False, False],), "allTrue [false, false]"),
]
