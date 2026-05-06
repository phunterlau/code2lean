"""Arithmetic: parity XOR of two non-negative integers."""

from __future__ import annotations


def parity_xor(a: int, b: int) -> bool:
    """Return True iff exactly one of a and b is odd."""
    return (a % 2) != (b % 2)
