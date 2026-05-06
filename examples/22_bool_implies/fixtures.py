"""Diff-test cases for bool_implies."""

FUNCTION = "bool_implies"

CASES = [
    ((False, False), "boolImplies false false"),
    ((False, True), "boolImplies false true"),
    ((True, False), "boolImplies true false"),
    ((True, True), "boolImplies true true"),
]
