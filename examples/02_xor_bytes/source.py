"""Crypto: byte-wise XOR (one-time-pad core operation)."""

from __future__ import annotations


def xor_bytes(a: bytes, b: bytes) -> bytes:
    """XOR two equal-length byte strings byte-by-byte.

    On unequal lengths, `zip` truncates to the shorter input.
    """
    return bytes(x ^ y for x, y in zip(a, b))
