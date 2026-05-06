"""Buggy variant: decodes little-endian while claiming big-endian."""

from __future__ import annotations


def bytes_to_nat_le_disguised(data: bytes) -> int:
    n = 0
    multiplier = 1
    for b in data:
        n += b * multiplier
        multiplier *= 256
    return n
