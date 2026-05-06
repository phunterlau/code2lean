"""Diff-test cases for reverse_list."""

FUNCTION = "reverse_list"


def to_lean_value(v):
    return "[" + ", ".join(str(x) for x in v) + "]"


CASES = [
    (([],),               "reverseList []"),
    (([7],),              "reverseList [7]"),
    (([1, 2, 3],),        "reverseList [1, 2, 3]"),
    (([5, 4, 3, 2, 1],),  "reverseList [5, 4, 3, 2, 1]"),
    (([0, 0, 1],),        "reverseList [0, 0, 1]"),
]
