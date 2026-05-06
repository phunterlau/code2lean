"""Adversarial pair: saturating byte addition."""

from __future__ import annotations


def saturating_add8_no_clamp(a: int, b: int) -> int:
    """Return min(a + b, 255). Inputs are byte-sized non-negative integers."""
    total = a + b
    if total > 255:
        return 255
    return total
