"""Lists: sum a list of non-negative integers."""

from __future__ import annotations


def list_sum(xs: list[int]) -> int:
    """Return the sum of all elements in xs."""
    total = 0
    for x in xs:
        total += x
    return total
