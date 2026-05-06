"""Diff-test cases for same_length."""

FUNCTION = "same_length"

CASES = [
    ((b"", b""), "sameLength [] []"),
    ((b"\x01", b"\x02"), "sameLength [1] [2]"),
    ((b"\x01", b""), "sameLength [1] []"),
    ((b"", b"\x02"), "sameLength [] [2]"),
    ((b"\x01\x02", b"\x03\x04"), "sameLength [1, 2] [3, 4]"),
    ((b"\x01\x02", b"\x03"), "sameLength [1, 2] [3]"),
]
