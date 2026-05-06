"""Diff-test cases for list_member."""

FUNCTION = "list_member"

CASES = [
    ((1, []),                "listMember 1 []"),
    ((1, [1, 2, 3]),         "listMember 1 [1, 2, 3]"),
    ((4, [1, 2, 3]),         "listMember 4 [1, 2, 3]"),
    ((3, [1, 2, 3]),         "listMember 3 [1, 2, 3]"),
    ((0, [0, 0, 0]),         "listMember 0 [0, 0, 0]"),
    ((9, [1, 2, 3, 4, 5]),   "listMember 9 [1, 2, 3, 4, 5]"),
]
