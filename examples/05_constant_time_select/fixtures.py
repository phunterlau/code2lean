"""Diff-test cases for constant_time_select."""

FUNCTION = "constant_time_select"

CASES = [
    ((True,  1, 2),    "constantTimeSelect true 1 2"),
    ((False, 1, 2),    "constantTimeSelect false 1 2"),
    ((True,  0, 999),  "constantTimeSelect true 0 999"),
    ((False, 100, 200),"constantTimeSelect false 100 200"),
    ((True,  42, 42),  "constantTimeSelect true 42 42"),
]
