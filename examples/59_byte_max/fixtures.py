"""Diff-test cases for byte_max."""

FUNCTION = "byte_max"

CASES = [
    ((b"",), "byteMax []"),
    ((b"\x00",), "byteMax [0]"),
    ((b"\x01\x05\x03",), "byteMax [1, 5, 3]"),
    ((b"\xff\x00",), "byteMax [255, 0]"),
    ((b"\x10\x20\x1f",), "byteMax [16, 32, 31]"),
]
