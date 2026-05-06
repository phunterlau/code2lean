"""Diff-test cases for xor_bytes."""

FUNCTION = "xor_bytes"


def to_lean_value(v):
    return "[" + ", ".join(str(b) for b in v) + "]"


CASES = [
    ((b"\x01\x02", b"\x03\x04"), "xorBytes [1, 2] [3, 4]"),
    ((b"\x00\x00", b"\xff\xff"), "xorBytes [0, 0] [255, 255]"),
    ((b"\xaa\xaa", b"\xaa\xaa"), "xorBytes [170, 170] [170, 170]"),
    ((b"", b""),                 "xorBytes [] []"),
    ((b"\xff", b"\x0f"),         "xorBytes [255] [15]"),
]
