"""Diff-test cases for xor_with_zero_key."""

FUNCTION = "xor_with_zero_key"

CASES = [
    ((b"",), "xorWithZeroKey []"),
    ((b"\x00",), "xorWithZeroKey [0]"),
    ((b"\x01\x02\x03",), "xorWithZeroKey [1, 2, 3]"),
    ((b"\xff\x00\x80",), "xorWithZeroKey [255, 0, 128]"),
]
