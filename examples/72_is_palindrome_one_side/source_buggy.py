"""Buggy variant: compares the first half against itself."""

from __future__ import annotations


def is_palindrome_one_side(xs: list[int]) -> bool:
    half = len(xs) // 2
    return xs[:half] == xs[:half]
