"""Diff-test cases for safe_int_parse."""

FUNCTION = "safe_int_parse"


def to_lean_value(v):
    return "none" if v is None else f"some {v}"


CASES = [
    (("0",), 'safeIntParse "0"'),
    (("1",), 'safeIntParse "1"'),
    (("2",), 'safeIntParse "2"'),
    (("10",), 'safeIntParse "10"'),
    (("",), 'safeIntParse ""'),
    (("x",), 'safeIntParse "x"'),
]
