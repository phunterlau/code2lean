"""Diff-test cases for bytes_eq_via_or_zero."""

FUNCTION = "bytes_eq_via_or_zero"

CASES = [
    ((b"", b""), "bytesEqViaOrZero [] []"),
    ((b"\x01", b"\x01"), "bytesEqViaOrZero [1] [1]"),
    ((b"\x01", b"\x02"), "bytesEqViaOrZero [1] [2]"),
    ((b"\x01\x02\x03", b"\x01\x02\x03"), "bytesEqViaOrZero [1, 2, 3] [1, 2, 3]"),
    ((b"\x01\x02\x03", b"\x01\x02\x09"), "bytesEqViaOrZero [1, 2, 3] [1, 2, 9]"),
    ((b"\x01\x02", b"\x01\x02\x03"), "bytesEqViaOrZero [1, 2] [1, 2, 3]"),
]
