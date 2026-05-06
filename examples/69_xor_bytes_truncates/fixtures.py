"""Diff-test cases for xor_bytes_truncates."""

FUNCTION = "xor_bytes_truncates"

CASES = [
    ((b"", b""), "xorBytesTruncates [] []"),
    ((b"\x01", b"\x02"), "xorBytesTruncates [1] [2]"),
    ((b"\x01\x02", b"\x03\x04"), "xorBytesTruncates [1, 2] [3, 4]"),
    ((b"\x01", b"\x02\x03"), "xorBytesTruncates [1] [2, 3]"),
    ((b"\xff", b"\x0f"), "xorBytesTruncates [255] [15]"),
]
