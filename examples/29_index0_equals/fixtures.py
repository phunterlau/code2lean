"""Diff-test cases for index0_equals."""

FUNCTION = "index0_equals"

CASES = [
    (([], 0), "index0Equals [] 0"),
    (([0], 0), "index0Equals [0] 0"),
    (([1], 0), "index0Equals [1] 0"),
    (([1, 2, 3], 1), "index0Equals [1, 2, 3] 1"),
    (([1, 2, 3], 2), "index0Equals [1, 2, 3] 2"),
    (([9, 9], 9), "index0Equals [9, 9] 9"),
]
