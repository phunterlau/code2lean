"""Spec-vs-implementation: parity via a fold."""

from __future__ import annotations


def parity_via_xor_fold(data: bytes) -> bool:
    """Return True iff the sum of all bytes is odd."""
    parity = 0
    for b in data:
        parity = (parity + b) % 2
    return parity == 1
