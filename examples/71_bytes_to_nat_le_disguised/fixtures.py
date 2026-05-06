"""Diff-test cases for bytes_to_nat_le_disguised."""

FUNCTION = "bytes_to_nat_le_disguised"

CASES = [
    ((b"",), "bytesToNatLeDisguised []"),
    ((b"\x00",), "bytesToNatLeDisguised [0]"),
    ((b"\x01",), "bytesToNatLeDisguised [1]"),
    ((b"\x01\x00",), "bytesToNatLeDisguised [1, 0]"),
    ((b"\x01\x02\x03",), "bytesToNatLeDisguised [1, 2, 3]"),
]
