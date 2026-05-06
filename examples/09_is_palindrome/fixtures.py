"""Diff-test cases for is_palindrome."""

FUNCTION = "is_palindrome"

CASES = [
    (([],),               "isPalindrome []"),
    (([1],),              "isPalindrome [1]"),
    (([1, 2, 1],),        "isPalindrome [1, 2, 1]"),
    (([1, 2, 3],),        "isPalindrome [1, 2, 3]"),
    (([1, 2, 2, 1],),     "isPalindrome [1, 2, 2, 1]"),
    (([1, 2, 3, 4, 5],),  "isPalindrome [1, 2, 3, 4, 5]"),
    (([7, 0, 7],),        "isPalindrome [7, 0, 7]"),
]
