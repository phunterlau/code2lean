"""Bytes: keep the low nibble."""

from __future__ import annotations


def mask_low_nibble(b: int) -> int:
    """Return b modulo 16, matching b & 0x0f for byte-sized inputs."""
    return b % 16
