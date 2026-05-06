"""Diff-test cases for product_or_one."""

FUNCTION = "product_or_one"

CASES = [
    (([],), "productOrOne []"),
    (([0],), "productOrOne [0]"),
    (([1],), "productOrOne [1]"),
    (([2, 3, 4],), "productOrOne [2, 3, 4]"),
    (([5, 1, 2],), "productOrOne [5, 1, 2]"),
    (([7, 0, 9],), "productOrOne [7, 0, 9]"),
]
