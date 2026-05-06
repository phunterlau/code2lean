"""Adversarial pair: count all occurrences."""

from __future__ import annotations


def count_occurrences_off_by_one(x: int, xs: list[int]) -> int:
    """Return how many times x appears in xs."""
    n = 0
    for y in xs:
        if y == x:
            n += 1
    return n
