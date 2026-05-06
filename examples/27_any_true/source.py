"""Booleans: any element is True."""

from __future__ import annotations


def any_true(xs: list[bool]) -> bool:
    """Return True iff at least one element of xs is True."""
    for x in xs:
        if x:
            return True
    return False
