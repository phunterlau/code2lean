"""Diff-test cases for byte_sum."""

FUNCTION = "byte_sum"

CASES = [
    ((b"",), "byteSum []"),
    ((b"\x00",), "byteSum [0]"),
    ((b"\x01\x02\x03",), "byteSum [1, 2, 3]"),
    ((b"\xff",), "byteSum [255]"),
    ((b"\x10\x20",), "byteSum [16, 32]"),
    ((b"\x05\x05\x05\x05",), "byteSum [5, 5, 5, 5]"),
]
