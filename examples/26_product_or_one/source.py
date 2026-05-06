"""Lists: multiply elements with one as the empty product."""

from __future__ import annotations


def product_or_one(xs: list[int]) -> int:
    """Return the product of xs, using 1 for the empty list."""
    acc = 1
    for x in xs:
        acc *= x
    return acc
