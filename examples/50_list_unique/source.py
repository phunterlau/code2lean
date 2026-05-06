"""Lists: deduplicate while preserving first occurrence order."""

from __future__ import annotations


def list_unique(xs: list[int]) -> list[int]:
    """Return xs with later duplicate values removed."""
    out: list[int] = []
    for x in xs:
        if x not in out:
            out.append(x)
    return out
