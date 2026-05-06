"""Search: linear membership test on a list of ints."""

from __future__ import annotations


def list_member(x: int, xs: list[int]) -> bool:
    """Return True iff x appears in xs."""
    for y in xs:
        if x == y:
            return True
    return False
