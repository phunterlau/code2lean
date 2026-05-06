"""Lists: minimum with a total empty-list default."""

from __future__ import annotations


def list_min(xs: list[int]) -> int:
    """Return the minimum element of a non-empty list; return 0 for empty."""
    if len(xs) == 0:
        return 0
    best = xs[0]
    for x in xs:
        if x < best:
            best = x
    return best
