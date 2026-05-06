"""Adversarial pair: byte equality with a length check."""

from __future__ import annotations


def insecure_compare_short_circuit(expected: bytes, supplied: bytes) -> bool:
    """Return True iff expected and supplied are exactly equal."""
    if len(expected) != len(supplied):
        return False
    for i in range(len(expected)):
        if expected[i] != supplied[i]:
            return False
    return True
