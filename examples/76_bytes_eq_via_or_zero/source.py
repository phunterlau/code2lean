"""Spec-vs-implementation: byte equality via accumulated mismatch."""

from __future__ import annotations


def bytes_eq_via_or_zero(a: bytes, b: bytes) -> bool:
    """Return True iff a equals b, scanning all paired bytes."""
    if len(a) != len(b):
        return False
    mismatch = False
    for x, y in zip(a, b):
        if x != y:
            mismatch = True
    return not mismatch
