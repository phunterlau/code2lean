"""Counting: number of occurrences of a value in a list."""

from __future__ import annotations


def count_occurrences(x: int, xs: list[int]) -> int:
    """Return how many times x appears in xs."""
    n = 0
    for y in xs:
        if y == x:
            n += 1
    return n
