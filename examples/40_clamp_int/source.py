"""Arithmetic: signed clamp."""

from __future__ import annotations


def clamp_int(x: int, lo: int, hi: int) -> int:
    """Clamp signed x into [lo, hi]. Caller ensures lo <= hi."""
    if x < lo:
        return lo
    if x > hi:
        return hi
    return x
