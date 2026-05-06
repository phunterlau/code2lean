"""Number theory: greatest common divisor."""

from __future__ import annotations


def gcd_two(a: int, b: int) -> int:
    """Return gcd(a, b) for non-negative integers."""
    if b == 0:
        return a
    return gcd_two(b, a % b)
