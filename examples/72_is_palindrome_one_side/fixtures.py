"""Diff-test cases for is_palindrome_one_side."""

FUNCTION = "is_palindrome_one_side"

CASES = [
    (([],), "isPalindromeOneSide []"),
    (([1],), "isPalindromeOneSide [1]"),
    (([1, 2, 1],), "isPalindromeOneSide [1, 2, 1]"),
    (([1, 2, 3],), "isPalindromeOneSide [1, 2, 3]"),
    (([1, 2, 2, 1],), "isPalindromeOneSide [1, 2, 2, 1]"),
]
