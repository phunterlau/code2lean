"""Buggy variant: wrong base case."""

from __future__ import annotations


def factorial_off_by_one(n: int) -> int:
    if n == 0:
        return 0
    return n * factorial_off_by_one(n - 1)
