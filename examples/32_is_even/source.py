"""Arithmetic: evenness predicate."""

from __future__ import annotations


def is_even(n: int) -> bool:
    """Return True iff n is even. Input is non-negative."""
    return n % 2 == 0
