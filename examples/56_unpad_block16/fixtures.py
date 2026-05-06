"""Diff-test cases for unpad_block16."""

FUNCTION = "unpad_block16"

CASES = [
    ((b"",), "unpadBlock16 []"),
    ((b"\x01",), "unpadBlock16 [1]"),
    ((b"\x05\x01",), "unpadBlock16 [5, 1]"),
    ((b"\x05\x02\x02",), "unpadBlock16 [5, 2, 2]"),
    ((b"\x05\x00",), "unpadBlock16 [5, 0]"),
    ((b"\x05\x09",), "unpadBlock16 [5, 9]"),
]
