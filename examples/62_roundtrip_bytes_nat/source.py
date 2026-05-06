"""Composition: fixed-width two-byte encode/decode."""

from __future__ import annotations


def roundtrip_bytes_nat(n: int) -> bool:
    """Return True iff two-byte big-endian encode/decode recovers n modulo 65536."""
    hi = (n // 256) % 256
    lo = n % 256
    decoded = hi * 256 + lo
    return decoded == (n % 65536)
