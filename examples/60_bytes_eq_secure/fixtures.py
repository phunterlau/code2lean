"""Diff-test cases for bytes_eq_secure."""

FUNCTION = "bytes_eq_secure"

CASES = [
    ((b"", b""), "bytesEqSecure [] []"),
    ((b"\x01", b"\x01"), "bytesEqSecure [1] [1]"),
    ((b"\x01", b"\x02"), "bytesEqSecure [1] [2]"),
    ((b"\x01\x02\x03", b"\x01\x02\x03"), "bytesEqSecure [1, 2, 3] [1, 2, 3]"),
    ((b"\x01\x02\x03", b"\x01\x02\x09"), "bytesEqSecure [1, 2, 3] [1, 2, 9]"),
    ((b"\x01\x02", b"\x01\x02\x03"), "bytesEqSecure [1, 2] [1, 2, 3]"),
]
