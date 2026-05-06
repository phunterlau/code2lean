"""Number theory: least common multiple."""

from __future__ import annotations


def lcm_two(a: int, b: int) -> int:
    """Return lcm(a, b) for non-negative integers, using 0 when either is 0."""
    def gcd(x: int, y: int) -> int:
        if y == 0:
            return x
        return gcd(y, x % y)

    if a == 0 or b == 0:
        return 0
    return (a // gcd(a, b)) * b
