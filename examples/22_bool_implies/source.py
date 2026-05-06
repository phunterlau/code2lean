"""Booleans: implication."""

from __future__ import annotations


def bool_implies(a: bool, b: bool) -> bool:
    """Return logical implication a -> b."""
    if a:
        return b
    return True
