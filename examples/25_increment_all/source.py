"""Lists: increment every element."""

from __future__ import annotations


def increment_all(xs: list[int]) -> list[int]:
    """Return a list where each element has been incremented by one."""
    out: list[int] = []
    for x in xs:
        out.append(x + 1)
    return out
