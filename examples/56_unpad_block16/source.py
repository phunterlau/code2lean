"""Bytes: remove simple PKCS#7-style padding."""

from __future__ import annotations


def unpad_block16(data: bytes) -> bytes:
    """Remove trailing padding indicated by the last byte when it is plausible."""
    if len(data) == 0:
        return b""
    pad_len = data[-1]
    if pad_len == 0 or pad_len > len(data):
        return data
    return data[:-pad_len]
