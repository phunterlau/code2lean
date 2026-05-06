"""Bytes: XOR with an all-zero key."""

from __future__ import annotations


def xor_with_zero_key(data: bytes) -> bytes:
    """Return data XOR an all-zero key of the same length, which is data."""
    return bytes(b ^ 0 for b in data)
