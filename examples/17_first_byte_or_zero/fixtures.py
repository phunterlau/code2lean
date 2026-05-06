"""Diff-test cases for first_byte_or_zero."""

FUNCTION = "first_byte_or_zero"

CASES = [
    ((b"",), "firstByteOrZero []"),
    ((b"\x00",), "firstByteOrZero [0]"),
    ((b"\x05",), "firstByteOrZero [5]"),
    ((b"\x09\x08\x07",), "firstByteOrZero [9, 8, 7]"),
    ((b"\xff\x00",), "firstByteOrZero [255, 0]"),
]
