"""Diff-test cases for ct_select_via_mask."""

FUNCTION = "ct_select_via_mask"

CASES = [
    ((True, 1, 2), "ctSelectViaMask true 1 2"),
    ((False, 1, 2), "ctSelectViaMask false 1 2"),
    ((True, 0, 999), "ctSelectViaMask true 0 999"),
    ((False, 100, 200), "ctSelectViaMask false 100 200"),
    ((True, 42, 42), "ctSelectViaMask true 42 42"),
]
