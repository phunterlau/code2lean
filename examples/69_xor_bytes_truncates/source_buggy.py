"""Buggy variant: silently truncates to the shorter input."""

from __future__ import annotations


def xor_bytes_truncates(a: bytes, b: bytes) -> bytes:
    return bytes(x ^ y for x, y in zip(a, b))
