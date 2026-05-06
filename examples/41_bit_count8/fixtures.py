"""Diff-test cases for bit_count8."""

FUNCTION = "bit_count8"

CASES = [
    ((0,), "bitCount8 0"),
    ((1,), "bitCount8 1"),
    ((3,), "bitCount8 3"),
    ((15,), "bitCount8 15"),
    ((128,), "bitCount8 128"),
    ((255,), "bitCount8 255"),
]
