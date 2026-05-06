"""Safer HMAC token verification demo.

Use hmac.compare_digest for comparison of secret MAC/tag values.
"""

from __future__ import annotations

import hashlib
import hmac

SECRET_KEY = b"demo-secret-key"


def make_tag(message: bytes) -> bytes:
    """Return an HMAC-SHA256 tag for a message."""
    return hmac.new(SECRET_KEY, message, hashlib.sha256).digest()


def verify_message(message: bytes, supplied_tag: bytes) -> bool:
    """Verify an HMAC tag using constant-time comparison for equal-length tags."""
    expected = make_tag(message)

    # Explicit length check is fine here because HMAC-SHA256 tags have a public,
    # fixed expected length. compare_digest avoids content-dependent early exit.
    if len(supplied_tag) != len(expected):
        return False

    return hmac.compare_digest(expected, supplied_tag)
