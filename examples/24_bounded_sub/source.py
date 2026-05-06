"""Arithmetic: subtraction clamped at zero."""

from __future__ import annotations


def bounded_sub(a: int, b: int) -> int:
    """Return a - b when a >= b, otherwise 0. Inputs are non-negative."""
    if a < b:
        return 0
    return a - b
