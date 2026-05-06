"""Arithmetic: maximum of two non-negative integers."""

from __future__ import annotations


def max2(a: int, b: int) -> int:
    """Return the larger of a and b. Inputs are non-negative."""
    if a < b:
        return b
    return a
