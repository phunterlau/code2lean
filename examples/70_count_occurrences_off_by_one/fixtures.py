"""Diff-test cases for count_occurrences_off_by_one."""

FUNCTION = "count_occurrences_off_by_one"

CASES = [
    ((1, []), "countOccurrencesOffByOne 1 []"),
    ((1, [1]), "countOccurrencesOffByOne 1 [1]"),
    ((1, [1, 1, 2]), "countOccurrencesOffByOne 1 [1, 1, 2]"),
    ((2, [1, 2, 3, 2]), "countOccurrencesOffByOne 2 [1, 2, 3, 2]"),
    ((9, [1, 2, 3]), "countOccurrencesOffByOne 9 [1, 2, 3]"),
]
