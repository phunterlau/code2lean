"""Bytes: read the first byte with a zero default."""

from __future__ import annotations


def first_byte_or_zero(data: bytes) -> int:
    """Return the first byte, or 0 when data is empty."""
    if len(data) == 0:
        return 0
    return data[0]
