"""Composition: padding followed by unpadding."""

from __future__ import annotations


def roundtrip_pad_unpad(data: bytes) -> bool:
    """Return True iff unpadding padded data recovers the original data."""
    pad_len = 16 - (len(data) % 16)
    padded = data + bytes([pad_len]) * pad_len
    last = padded[-1]
    unpadded = padded[:-last]
    return unpadded == data
