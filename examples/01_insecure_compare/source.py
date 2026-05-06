"""Crypto: timing-leaky byte equality (early-exit comparison)."""

from __future__ import annotations


def insecure_compare(expected: bytes, supplied: bytes) -> bool:
    """Return True iff the two byte strings are equal."""
    if len(expected) != len(supplied):
        return False
    for i in range(len(expected)):
        if expected[i] != supplied[i]:
            return False
    return True
