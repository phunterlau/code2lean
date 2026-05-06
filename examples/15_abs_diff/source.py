"""Arithmetic: absolute difference of two non-negative integers."""

from __future__ import annotations


def abs_diff(a: int, b: int) -> int:
    """Return the non-negative distance between a and b."""
    if a < b:
        return b - a
    return a - b
