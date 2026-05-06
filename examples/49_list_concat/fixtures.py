"""Diff-test cases for list_concat."""

FUNCTION = "list_concat"

CASES = [
    (([], []), "listConcat [] []"),
    (([1], []), "listConcat [1] []"),
    (([], [2]), "listConcat [] [2]"),
    (([1, 2], [3, 4]), "listConcat [1, 2] [3, 4]"),
    (([0, 0], [1]), "listConcat [0, 0] [1]"),
]
