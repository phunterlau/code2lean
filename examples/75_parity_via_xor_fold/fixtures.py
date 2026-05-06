"""Diff-test cases for parity_via_xor_fold."""

FUNCTION = "parity_via_xor_fold"

CASES = [
    ((b"",), "parityViaXorFold []"),
    ((b"\x01",), "parityViaXorFold [1]"),
    ((b"\x02",), "parityViaXorFold [2]"),
    ((b"\x01\x02",), "parityViaXorFold [1, 2]"),
    ((b"\xff\x01",), "parityViaXorFold [255, 1]"),
]
