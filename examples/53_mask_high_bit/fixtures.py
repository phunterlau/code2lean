"""Diff-test cases for mask_high_bit."""

FUNCTION = "mask_high_bit"

CASES = [
    ((0,), "maskHighBit 0"),
    ((1,), "maskHighBit 1"),
    ((127,), "maskHighBit 127"),
    ((128,), "maskHighBit 128"),
    ((255,), "maskHighBit 255"),
]
