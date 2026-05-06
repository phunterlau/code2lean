"""Diff-test cases for roundtrip_bytes_nat."""

FUNCTION = "roundtrip_bytes_nat"

CASES = [
    ((0,), "roundtripBytesNat 0"),
    ((1,), "roundtripBytesNat 1"),
    ((255,), "roundtripBytesNat 255"),
    ((256,), "roundtripBytesNat 256"),
    ((65535,), "roundtripBytesNat 65535"),
    ((70000,), "roundtripBytesNat 70000"),
]
