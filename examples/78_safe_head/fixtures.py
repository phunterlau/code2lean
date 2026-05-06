"""Diff-test cases for safe_head."""

FUNCTION = "safe_head"


def to_lean_value(v):
    return "none" if v is None else f"some {v}"


CASES = [
    (([],), "safeHead []"),
    (([0],), "safeHead [0]"),
    (([7],), "safeHead [7]"),
    (([1, 2, 3],), "safeHead [1, 2, 3]"),
]
