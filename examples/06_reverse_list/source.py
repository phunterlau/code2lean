"""List ops: reverse a list of ints."""

from __future__ import annotations


def reverse_list(xs: list[int]) -> list[int]:
    """Return the reversal of xs."""
    out: list[int] = []
    for x in xs:
        out = [x] + out
    return out
