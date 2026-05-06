"""Bytes: population count of one byte."""

from __future__ import annotations


def bit_count8(n: int) -> int:
    """Return the number of 1 bits in the low 8 bits of n."""
    count = 0
    for _ in range(8):
        count += n % 2
        n = n // 2
    return count
