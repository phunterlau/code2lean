"""Diff-test cases for saturating_add8_no_clamp."""

FUNCTION = "saturating_add8_no_clamp"

CASES = [
    ((0, 0), "saturatingAdd8NoClamp 0 0"),
    ((1, 2), "saturatingAdd8NoClamp 1 2"),
    ((200, 20), "saturatingAdd8NoClamp 200 20"),
    ((200, 100), "saturatingAdd8NoClamp 200 100"),
    ((255, 0), "saturatingAdd8NoClamp 255 0"),
]
