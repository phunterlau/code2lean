"""Adversarial pair: correct factorial."""

from __future__ import annotations


def factorial_off_by_one(n: int) -> int:
    """Return n! for n >= 0."""
    if n == 0:
        return 1
    return n * factorial_off_by_one(n - 1)
