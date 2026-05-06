"""Option: safe list lookup."""

from __future__ import annotations


def safe_lookup(xs: list[int], i: int) -> int | None:
    """Return None when i is out of range, otherwise the element at i."""
    if i >= len(xs):
        return None
    return xs[i]
