"""Composition: reversing twice."""

from __future__ import annotations


def reverse_twice_is_id(xs: list[int]) -> bool:
    """Return True iff reversing xs twice yields xs."""
    return list(reversed(list(reversed(xs)))) == xs
