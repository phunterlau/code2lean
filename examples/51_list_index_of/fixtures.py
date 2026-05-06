"""Diff-test cases for list_index_of."""

FUNCTION = "list_index_of"

CASES = [
    (([], 1), "listIndexOf [] 1"),
    (([1], 1), "listIndexOf [1] 1"),
    (([1, 2, 3], 2), "listIndexOf [1, 2, 3] 2"),
    (([1, 2, 1], 1), "listIndexOf [1, 2, 1] 1"),
    (([4, 5, 6], 9), "listIndexOf [4, 5, 6] 9"),
]
