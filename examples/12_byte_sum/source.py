"""Bytes: sum byte values."""

from __future__ import annotations


def byte_sum(data: bytes) -> int:
    """Return the sum of all byte values in data."""
    total = 0
    for b in data:
        total += b
    return total
