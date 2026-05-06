"""Buggy variant: omits the saturation branch."""

from __future__ import annotations


def saturating_add8_no_clamp(a: int, b: int) -> int:
    return a + b
