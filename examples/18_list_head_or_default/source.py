"""Lists: read the first element with a zero default."""

from __future__ import annotations


def list_head_or_default(xs: list[int]) -> int:
    """Return the first list element, or 0 when xs is empty."""
    if len(xs) == 0:
        return 0
    return xs[0]
