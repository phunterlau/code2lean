"""Arithmetic: minimum of two non-negative integers."""

from __future__ import annotations


def min2(a: int, b: int) -> int:
    """Return the smaller of a and b. Inputs are non-negative."""
    if a < b:
        return a
    return b
