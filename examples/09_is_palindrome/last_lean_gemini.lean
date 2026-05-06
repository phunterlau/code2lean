import Std

namespace RepoVerifyAutogen

def isPalindrome (xs : List Int) : Bool :=
  xs == xs.reverse

theorem isPalindrome_correct (xs : List Int) :
  isPalindrome xs = true ↔ xs = xs.reverse := by
  unfold isPalindrome
  exact beq_iff_eq

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval isPalindrome []
#eval isPalindrome [1]
#eval isPalindrome [1, 2, 1]
#eval isPalindrome [1, 2, 3]
#eval isPalindrome [1, 2, 2, 1]
#eval isPalindrome [1, 2, 3, 4, 5]
#eval isPalindrome [7, 0, 7]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.isPalindrome_correct

