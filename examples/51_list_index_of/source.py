"""Lists: first index of a value with -1 as the absent sentinel."""

from __future__ import annotations


def list_index_of(xs: list[int], x: int) -> int:
    """Return the first index of x in xs, or -1 when x is absent."""
    i = 0
    for y in xs:
        if y == x:
            return i
        i += 1
    return -1
