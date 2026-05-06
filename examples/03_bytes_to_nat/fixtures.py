"""Diff-test cases for bytes_to_nat."""

FUNCTION = "bytes_to_nat"

CASES = [
    ((b"",),             "bytesToNat []"),
    ((b"\x00",),         "bytesToNat [0]"),
    ((b"\x01",),         "bytesToNat [1]"),
    ((b"\xff",),         "bytesToNat [255]"),
    ((b"\x01\x00",),     "bytesToNat [1, 0]"),
    ((b"\x01\x02\x03",), "bytesToNat [1, 2, 3]"),
    ((b"\xff\xff",),     "bytesToNat [255, 255]"),
]
