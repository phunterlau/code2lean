"""Diff-test cases for mask_low_nibble."""

FUNCTION = "mask_low_nibble"

CASES = [
    ((0,), "maskLowNibble 0"),
    ((15,), "maskLowNibble 15"),
    ((16,), "maskLowNibble 16"),
    ((31,), "maskLowNibble 31"),
    ((255,), "maskLowNibble 255"),
]
