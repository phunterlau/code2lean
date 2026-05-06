"""Crypto: branchless conditional-select primitive (spec form)."""

from __future__ import annotations


def constant_time_select(cond: bool, a: int, b: int) -> int:
    """Return a when cond is True, else b.

    This is the *specification* a constant-time implementation must satisfy;
    the implementation here is straightforward Python.
    """
    return a if cond else b
