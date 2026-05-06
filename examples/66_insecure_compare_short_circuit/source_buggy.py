"""Buggy variant: ignores trailing bytes in supplied."""

from __future__ import annotations


def insecure_compare_short_circuit(expected: bytes, supplied: bytes) -> bool:
    for i in range(len(expected)):
        if i >= len(supplied) or expected[i] != supplied[i]:
            return False
    return True
