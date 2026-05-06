"""Arithmetic: small modular exponentiation."""

from __future__ import annotations


def pow_mod_small(a: int, b: int, m: int) -> int:
    """Return (a ** b) % m for non-negative inputs, or 0 when m is 0."""
    if m == 0:
        return 0
    acc = 1
    for _ in range(b):
        acc = (acc * a) % m
    return acc
