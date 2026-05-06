"""Diff-test cases for pad_to_block16."""

FUNCTION = "pad_to_block16"

CASES = [
    ((b"",), "padToBlock16 []"),
    ((b"\x01",), "padToBlock16 [1]"),
    ((b"\x01\x02\x03",), "padToBlock16 [1, 2, 3]"),
    ((bytes(range(15)),), "padToBlock16 [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]"),
    ((bytes(range(16)),), "padToBlock16 [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]"),
]
