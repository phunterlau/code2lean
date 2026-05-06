"""Diff-test cases for palindrome_iff_reverse_eq."""

FUNCTION = "palindrome_iff_reverse_eq"

CASES = [
    (([],), "palindromeIffReverseEq []"),
    (([1],), "palindromeIffReverseEq [1]"),
    (([1, 2, 1],), "palindromeIffReverseEq [1, 2, 1]"),
    (([1, 2, 3],), "palindromeIffReverseEq [1, 2, 3]"),
    (([1, 2, 2, 1],), "palindromeIffReverseEq [1, 2, 2, 1]"),
]
