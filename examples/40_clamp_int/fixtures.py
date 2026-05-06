"""Diff-test cases for clamp_int."""

FUNCTION = "clamp_int"

CASES = [
    ((5, 0, 10), "clampInt 5 0 10"),
    ((-1, 0, 10), "clampInt (-1) 0 10"),
    ((100, 0, 10), "clampInt 100 0 10"),
    ((-50, -10, 10), "clampInt (-50) (-10) 10"),
    ((7, -10, 10), "clampInt 7 (-10) 10"),
]
