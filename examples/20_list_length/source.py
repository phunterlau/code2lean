"""Lists: compute length by counting elements."""

from __future__ import annotations


def list_length(xs: list[int]) -> int:
    """Return the number of elements in xs."""
    n = 0
    for _ in xs:
        n += 1
    return n
