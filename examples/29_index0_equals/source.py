"""Lists: compare the first element against a value."""

from __future__ import annotations


def index0_equals(xs: list[int], x: int) -> bool:
    """Return True iff xs is non-empty and its first element equals x."""
    if len(xs) == 0:
        return False
    return xs[0] == x
