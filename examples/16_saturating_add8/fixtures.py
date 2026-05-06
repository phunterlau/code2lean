"""Diff-test cases for saturating_add8."""

FUNCTION = "saturating_add8"

CASES = [
    ((0, 0), "saturatingAdd8 0 0"),
    ((1, 2), "saturatingAdd8 1 2"),
    ((200, 20), "saturatingAdd8 200 20"),
    ((200, 100), "saturatingAdd8 200 100"),
    ((255, 0), "saturatingAdd8 255 0"),
    ((128, 127), "saturatingAdd8 128 127"),
]
