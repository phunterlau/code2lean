"""Buggy variant: swapped clamp outputs."""

from __future__ import annotations


def clamp_swapped_branches(x: int, lo: int, hi: int) -> int:
    if x < lo:
        return hi
    if x > hi:
        return lo
    return x
