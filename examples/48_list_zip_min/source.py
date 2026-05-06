"""Lists: element-wise min, truncating to the shorter list."""

from __future__ import annotations


def list_zip_min(xs: list[int], ys: list[int]) -> list[int]:
    """Return element-wise min over pairs from xs and ys."""
    out: list[int] = []
    for x, y in zip(xs, ys):
        if x < y:
            out.append(x)
        else:
            out.append(y)
    return out
