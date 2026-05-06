"""Spec-vs-implementation: select via arithmetic mask."""

from __future__ import annotations


def ct_select_via_mask(cond: bool, a: int, b: int) -> int:
    """Return a when cond is True, else b, using an arithmetic mask."""
    cond_int = 1 if cond else 0
    return cond_int * a + (1 - cond_int) * b
