"""Lists: take the positive prefix."""

from __future__ import annotations


def list_take_while_pos(xs: list[int]) -> list[int]:
    """Return the longest prefix of elements greater than 0."""
    out: list[int] = []
    for x in xs:
        if x == 0:
            return out
        out.append(x)
    return out
