"""Arithmetic: oddness predicate."""

from __future__ import annotations


def is_odd(n: int) -> bool:
    """Return True iff n is odd. Input is non-negative."""
    return n % 2 == 1
