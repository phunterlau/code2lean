"""Arithmetic: power-of-two predicate."""

from __future__ import annotations


def is_power_of_two(n: int) -> bool:
    """Return True iff n is a positive power of two."""
    if n == 0:
        return False
    while n % 2 == 0:
        n = n // 2
    return n == 1
