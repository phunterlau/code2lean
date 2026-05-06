"""Diff-test cases for insecure_compare_short_circuit."""

FUNCTION = "insecure_compare_short_circuit"

CASES = [
    ((b"", b""), "insecureCompareShortCircuit [] []"),
    ((b"\x01", b"\x01"), "insecureCompareShortCircuit [1] [1]"),
    ((b"\x01", b"\x02"), "insecureCompareShortCircuit [1] [2]"),
    ((b"\x01", b"\x01\x02"), "insecureCompareShortCircuit [1] [1, 2]"),
    ((b"\x01\x02", b"\x01"), "insecureCompareShortCircuit [1, 2] [1]"),
]
