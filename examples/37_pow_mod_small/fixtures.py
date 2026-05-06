"""Diff-test cases for pow_mod_small."""

FUNCTION = "pow_mod_small"

CASES = [
    ((2, 0, 5), "powModSmall 2 0 5"),
    ((2, 3, 5), "powModSmall 2 3 5"),
    ((3, 4, 7), "powModSmall 3 4 7"),
    ((10, 2, 6), "powModSmall 10 2 6"),
    ((5, 3, 0), "powModSmall 5 3 0"),
]
