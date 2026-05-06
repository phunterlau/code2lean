"""Diff-test cases for nat_to_bytes_be."""

FUNCTION = "nat_to_bytes_be"

CASES = [
    ((0,), "natToBytesBe 0"),
    ((1,), "natToBytesBe 1"),
    ((255,), "natToBytesBe 255"),
    ((256,), "natToBytesBe 256"),
    ((258,), "natToBytesBe 258"),
    ((65535,), "natToBytesBe 65535"),
]
