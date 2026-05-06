"""Bytes: check whether every byte is zero."""

from __future__ import annotations


def all_zero(data: bytes) -> bool:
    """Return True iff every byte in data is zero."""
    for b in data:
        if b != 0:
            return False
    return True
