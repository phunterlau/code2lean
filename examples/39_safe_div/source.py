"""Arithmetic: safe division with an Option-like result."""

from __future__ import annotations


def safe_div(a: int, b: int) -> int | None:
    """Return a // b, or None when b is 0. Inputs are non-negative."""
    if b == 0:
        return None
    return a // b
