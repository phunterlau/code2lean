"""Adversarial pair: correct clamp."""

from __future__ import annotations


def clamp_swapped_branches(x: int, lo: int, hi: int) -> int:
    """Clamp x into [lo, hi]. Caller ensures lo <= hi."""
    if x < lo:
        return lo
    if x > hi:
        return hi
    return x
