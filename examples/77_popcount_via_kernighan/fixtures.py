"""Diff-test cases for popcount_via_kernighan."""

FUNCTION = "popcount_via_kernighan"

CASES = [
    ((0,), "popcountViaKernighan 0"),
    ((1,), "popcountViaKernighan 1"),
    ((3,), "popcountViaKernighan 3"),
    ((15,), "popcountViaKernighan 15"),
    ((128,), "popcountViaKernighan 128"),
    ((255,), "popcountViaKernighan 255"),
]
