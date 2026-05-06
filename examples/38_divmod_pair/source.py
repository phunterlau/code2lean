"""Arithmetic: quotient and remainder pair."""

from __future__ import annotations


def divmod_pair(a: int, b: int) -> tuple[int, int]:
    """Return (a // b, a % b), or (0, a) when b is 0."""
    if b == 0:
        return (0, a)
    return (a // b, a % b)
