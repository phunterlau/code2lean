"""Bytes: compare public lengths."""

from __future__ import annotations


def same_length(a: bytes, b: bytes) -> bool:
    """Return True iff a and b have the same length."""
    return len(a) == len(b)
