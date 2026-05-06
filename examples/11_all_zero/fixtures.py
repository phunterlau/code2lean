"""Diff-test cases for all_zero."""

FUNCTION = "all_zero"

CASES = [
    ((b"",), "allZero []"),
    ((b"\x00",), "allZero [0]"),
    ((b"\x00\x00\x00",), "allZero [0, 0, 0]"),
    ((b"\x01",), "allZero [1]"),
    ((b"\x00\x02\x00",), "allZero [0, 2, 0]"),
    ((b"\xff",), "allZero [255]"),
]
