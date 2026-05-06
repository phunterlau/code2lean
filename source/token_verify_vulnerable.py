"""Vulnerable HMAC token verification demo.

This file is intentionally insecure. It demonstrates a case where a
functional theorem can be true while the implementation still leaks timing
information through early exit.
"""

from __future__ import annotations

import hashlib
import hmac

SECRET_KEY = b"demo-secret-key"


def make_tag(message: bytes) -> bytes:
    """Return an HMAC-SHA256 tag for a message."""
    return hmac.new(SECRET_KEY, message, hashlib.sha256).digest()


def insecure_compare(expected: bytes, supplied: bytes) -> bool:
    """Return whether two byte strings are equal.

    Functionally correct, but timing-leaky: it returns as soon as the first
    differing byte is found. For secret tags, this can leak the matching prefix
    length through timing.
    """
    if len(expected) != len(supplied):
        return False

    for i in range(len(expected)):
        if expected[i] != supplied[i]:
            return False

    return True


def verify_message(message: bytes, supplied_tag: bytes) -> bool:
    """Verify an HMAC tag using the vulnerable comparison routine."""
    expected = make_tag(message)
    return insecure_compare(expected, supplied_tag)
