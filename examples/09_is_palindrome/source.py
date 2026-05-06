"""Composition: a list equals its reversal."""

from __future__ import annotations


def is_palindrome(xs: list[int]) -> bool:
    """Return True iff xs equals its own reversal."""
    return xs == xs[::-1]
