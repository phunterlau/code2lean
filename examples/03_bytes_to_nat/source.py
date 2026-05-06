"""Crypto: big-endian bytes to non-negative integer (DER/ECDSA-style)."""

from __future__ import annotations


def bytes_to_nat(data: bytes) -> int:
    """Interpret `data` as a big-endian unsigned integer."""
    n = 0
    for b in data:
        n = n * 256 + b
    return n
