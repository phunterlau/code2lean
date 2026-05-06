"""Spec-vs-implementation: popcount by repeated division."""

from __future__ import annotations


def popcount_via_kernighan(n: int) -> int:
    """Return the number of 1 bits in the low 8 bits of n."""
    count = 0
    for _ in range(8):
        if n % 2 == 1:
            count += 1
        n = n // 2
    return count
