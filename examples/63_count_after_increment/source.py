"""Composition: count positives after incrementing."""

from __future__ import annotations


def count_after_increment(xs: list[int]) -> bool:
    """Return True iff incrementing every element does not reduce positive count."""
    before = 0
    after = 0
    for x in xs:
        if x > 0:
            before += 1
        if x + 1 > 0:
            after += 1
    return before <= after
