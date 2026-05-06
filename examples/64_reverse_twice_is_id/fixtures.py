"""Diff-test cases for reverse_twice_is_id."""

FUNCTION = "reverse_twice_is_id"

CASES = [
    (([],), "reverseTwiceIsId []"),
    (([1],), "reverseTwiceIsId [1]"),
    (([1, 2, 3],), "reverseTwiceIsId [1, 2, 3]"),
    (([0, 0, 1],), "reverseTwiceIsId [0, 0, 1]"),
]
