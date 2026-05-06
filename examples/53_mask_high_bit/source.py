"""Bytes: clear the high bit."""

from __future__ import annotations


def mask_high_bit(b: int) -> int:
    """Return b modulo 128, matching b & 0x7f for byte-sized inputs."""
    return b % 128
