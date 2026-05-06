"""Adversarial pair: big-endian byte decoding."""

from __future__ import annotations


def bytes_to_nat_le_disguised(data: bytes) -> int:
    """Interpret data as a big-endian unsigned integer."""
    n = 0
    for b in data:
        n = n * 256 + b
    return n
