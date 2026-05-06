"""Bytes: maximum byte with zero as empty default."""

from __future__ import annotations


def byte_max(data: bytes) -> int:
    """Return the maximum byte value, or 0 for empty data."""
    best = 0
    for b in data:
        if best < b:
            best = b
    return best
