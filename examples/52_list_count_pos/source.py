"""Lists: count positive elements."""

from __future__ import annotations


def list_count_pos(xs: list[int]) -> int:
    """Return how many elements of xs are greater than 0."""
    n = 0
    for x in xs:
        if x > 0:
            n += 1
    return n
