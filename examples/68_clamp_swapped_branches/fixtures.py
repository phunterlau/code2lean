"""Diff-test cases for clamp_swapped_branches."""

FUNCTION = "clamp_swapped_branches"

CASES = [
    ((5, 0, 10), "clampSwappedBranches 5 0 10"),
    ((-1, 0, 10), "clampSwappedBranches (-1) 0 10"),
    ((100, 0, 10), "clampSwappedBranches 100 0 10"),
    ((0, 0, 10), "clampSwappedBranches 0 0 10"),
    ((10, 0, 10), "clampSwappedBranches 10 0 10"),
]
