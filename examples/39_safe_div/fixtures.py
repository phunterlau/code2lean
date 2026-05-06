"""Diff-test cases for safe_div."""

FUNCTION = "safe_div"


def to_lean_value(v):
    return "none" if v is None else f"some {v}"


CASES = [
    ((0, 0), "safeDiv 0 0"),
    ((7, 0), "safeDiv 7 0"),
    ((8, 2), "safeDiv 8 2"),
    ((7, 3), "safeDiv 7 3"),
    ((15, 5), "safeDiv 15 5"),
]
