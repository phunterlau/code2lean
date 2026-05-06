"""Diff-test cases for list_zip_min."""

FUNCTION = "list_zip_min"

CASES = [
    (([], []), "listZipMin [] []"),
    (([1], []), "listZipMin [1] []"),
    (([], [2]), "listZipMin [] [2]"),
    (([1, 5, 3], [2, 4, 6]), "listZipMin [1, 5, 3] [2, 4, 6]"),
    (([9, 8], [1, 2, 3]), "listZipMin [9, 8] [1, 2, 3]"),
]
