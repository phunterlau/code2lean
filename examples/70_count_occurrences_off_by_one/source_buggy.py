"""Buggy variant: skips the first list element."""

from __future__ import annotations


def count_occurrences_off_by_one(x: int, xs: list[int]) -> int:
    n = 0
    for y in xs[1:]:
        if y == x:
            n += 1
    return n
