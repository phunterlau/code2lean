"""Lists: filter even non-negative integers."""

from __future__ import annotations


def list_filter_even(xs: list[int]) -> list[int]:
    """Return the elements of xs that are even."""
    out: list[int] = []
    for x in xs:
        if x % 2 == 0:
            out.append(x)
    return out
