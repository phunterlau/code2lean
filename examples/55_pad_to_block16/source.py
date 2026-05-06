"""Bytes: PKCS#7-style padding to a 16-byte block."""

from __future__ import annotations


def pad_to_block16(data: bytes) -> bytes:
    """Pad data to the next multiple of 16 bytes."""
    pad_len = 16 - (len(data) % 16)
    return data + bytes([pad_len]) * pad_len
