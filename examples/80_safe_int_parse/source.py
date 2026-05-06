"""Option: parse a small decimal string."""

from __future__ import annotations


def safe_int_parse(text: str) -> int | None:
    """Parse a small non-negative decimal string, or None when unsupported."""
    if text == "0":
        return 0
    if text == "1":
        return 1
    if text == "2":
        return 2
    if text == "10":
        return 10
    return None
