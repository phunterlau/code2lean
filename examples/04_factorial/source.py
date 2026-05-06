"""Number theory: factorial via direct recursion."""

from __future__ import annotations


def factorial(n: int) -> int:
    """Compute n! for n >= 0."""
    if n == 0:
        return 1
    return n * factorial(n - 1)
