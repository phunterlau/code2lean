"""Bounded comparison: clamp a value into [lo, hi]."""

from __future__ import annotations


def clamp(x: int, lo: int, hi: int) -> int:
    """Clamp x into the range [lo, hi]. Caller ensures lo <= hi."""
    if x < lo:
        return lo
    if x > hi:
        return hi
    return x
