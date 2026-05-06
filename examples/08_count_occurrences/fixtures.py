"""Diff-test cases for count_occurrences."""

FUNCTION = "count_occurrences"

CASES = [
    ((1, []),                 "countOccurrences 1 []"),
    ((1, [1, 1, 1]),          "countOccurrences 1 [1, 1, 1]"),
    ((2, [1, 2, 3, 2]),       "countOccurrences 2 [1, 2, 3, 2]"),
    ((5, [1, 2, 3]),          "countOccurrences 5 [1, 2, 3]"),
    ((0, [0, 1, 0, 1, 0]),    "countOccurrences 0 [0, 1, 0, 1, 0]"),
    ((7, [7, 7, 7, 7, 7, 7]), "countOccurrences 7 [7, 7, 7, 7, 7, 7]"),
]
