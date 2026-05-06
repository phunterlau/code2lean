"""Composition: palindrome predicate equivalence."""

from __future__ import annotations


def palindrome_iff_reverse_eq(xs: list[int]) -> bool:
    """Return True iff the palindrome test agrees with reverse-equality."""
    palindrome = xs == xs[::-1]
    reverse_eq = list(reversed(xs)) == xs
    return palindrome == reverse_eq
