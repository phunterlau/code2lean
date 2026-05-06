"""Diff-test cases for roundtrip_pad_unpad."""

FUNCTION = "roundtrip_pad_unpad"

CASES = [
    ((b"",), "roundtripPadUnpad []"),
    ((b"\x01",), "roundtripPadUnpad [1]"),
    ((b"\x01\x02\x03",), "roundtripPadUnpad [1, 2, 3]"),
    ((bytes(range(15)),), "roundtripPadUnpad [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]"),
]
