"""Option: safe list head."""

from __future__ import annotations


def safe_head(xs: list[int]) -> int | None:
    """Return None for an empty list, otherwise Some/head."""
    if len(xs) == 0:
        return None
    return xs[0]
