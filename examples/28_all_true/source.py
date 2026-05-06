"""Booleans: all elements are True."""

from __future__ import annotations


def all_true(xs: list[bool]) -> bool:
    """Return True iff every element of xs is True."""
    for x in xs:
        if not x:
            return False
    return True
