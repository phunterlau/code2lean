"""Diff-test cases for safe_lookup."""

FUNCTION = "safe_lookup"


def to_lean_value(v):
    return "none" if v is None else f"some {v}"


CASES = [
    (([], 0), "safeLookup [] 0"),
    (([1], 0), "safeLookup [1] 0"),
    (([1], 1), "safeLookup [1] 1"),
    (([5, 6, 7], 1), "safeLookup [5, 6, 7] 1"),
    (([5, 6, 7], 3), "safeLookup [5, 6, 7] 3"),
]
