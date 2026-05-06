"""Diff-test cases for any_true."""

FUNCTION = "any_true"

CASES = [
    (([],), "anyTrue []"),
    (([False],), "anyTrue [false]"),
    (([True],), "anyTrue [true]"),
    (([False, False, True],), "anyTrue [false, false, true]"),
    (([False, False],), "anyTrue [false, false]"),
    (([True, False, True],), "anyTrue [true, false, true]"),
]
