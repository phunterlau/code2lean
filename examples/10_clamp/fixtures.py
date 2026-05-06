"""Diff-test cases for clamp.

Note: clamp's spec allows negative inputs, so the Lean translation should use
`Int`, not `Nat`. Negative literals are parenthesized in the Lean call.
"""

FUNCTION = "clamp"

CASES = [
    ((5, 0, 10),     "clamp 5 0 10"),
    ((-1, 0, 10),    "clamp (-1) 0 10"),
    ((100, 0, 10),   "clamp 100 0 10"),
    ((0, 0, 10),     "clamp 0 0 10"),
    ((10, 0, 10),    "clamp 10 0 10"),
    ((-50, -10, 10), "clamp (-50) (-10) 10"),
    ((7, -10, 10),   "clamp 7 (-10) 10"),
]
