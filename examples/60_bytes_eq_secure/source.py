"""Bytes: constant-time-style equality specification."""

from __future__ import annotations


def bytes_eq_secure(a: bytes, b: bytes) -> bool:
    """Return True iff a equals b, without content-dependent early return."""
    same = len(a) == len(b)
    for x, y in zip(a, b):
        if x != y:
            same = False
    return same
