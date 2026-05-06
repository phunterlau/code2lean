"""Booleans: encode a Bool as a Nat-like integer."""

from __future__ import annotations


def bool_to_nat(flag: bool) -> int:
    """Return 1 for True and 0 for False."""
    if flag:
        return 1
    return 0
