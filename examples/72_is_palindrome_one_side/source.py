"""Adversarial pair: full palindrome test."""

from __future__ import annotations


def is_palindrome_one_side(xs: list[int]) -> bool:
    """Return True iff xs equals its reverse."""
    return xs == xs[::-1]
