"""Diff-test cases for insecure_compare."""

FUNCTION = "insecure_compare"

CASES = [
    ((b"\x01\x02\x03", b"\x01\x02\x03"), "insecureCompare [1, 2, 3] [1, 2, 3]"),
    ((b"\x01\x02\x03", b"\x09\x02\x03"), "insecureCompare [1, 2, 3] [9, 2, 3]"),
    ((b"\x01\x02\x03", b"\x01\x02\x09"), "insecureCompare [1, 2, 3] [1, 2, 9]"),
    ((b"\x01\x02\x03", b"\x01\x02"),     "insecureCompare [1, 2, 3] [1, 2]"),
    ((b"", b""),                          "insecureCompare [] []"),
    ((b"", b"\x01"),                      "insecureCompare [] [1]"),
]
