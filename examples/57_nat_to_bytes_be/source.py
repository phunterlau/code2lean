"""Encoding: non-negative integer to big-endian bytes."""

from __future__ import annotations


def nat_to_bytes_be(n: int) -> bytes:
    """Return the shortest big-endian byte encoding of n, using b'\\x00' for 0."""
    if n == 0:
        return b"\x00"
    out: list[int] = []
    while n > 0:
        out = [n % 256] + out
        n = n // 256
    return bytes(out)
