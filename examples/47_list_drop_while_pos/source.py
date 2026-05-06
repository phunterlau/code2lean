"""Lists: drop the positive prefix."""

from __future__ import annotations


def list_drop_while_pos(xs: list[int]) -> list[int]:
    """Return the suffix beginning at the first 0, or [] when all are positive."""
    i = 0
    while i < len(xs):
        if xs[i] == 0:
            return xs[i:]
        i += 1
    return []
