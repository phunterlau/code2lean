"""Adversarial pair: byte-wise XOR that rejects length mismatch."""

from __future__ import annotations


def xor_bytes_truncates(a: bytes, b: bytes) -> bytes:
    """XOR equal-length byte strings; return empty bytes when lengths differ."""
    if len(a) != len(b):
        return b""
    return bytes(x ^ y for x, y in zip(a, b))
