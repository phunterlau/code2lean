import Std

namespace RepoVerifyAutogen

@[simp]
def countOccurrences (x : Int) (xs : List Int) : Nat :=
  match xs with
  | [] => 0
  | y :: ys => if y = x then 1 + countOccurrences x ys else countOccurrences x ys

theorem countOccurrences_correct (x : Int) (xs ys : List Int) :
  countOccurrences x (xs ++ ys) = countOccurrences x xs + countOccurrences x ys := by
  induction xs with
  | nil => simp
  | cons z zs ih =>
    simp
    by_cases h : z = x
    · simp [h]
      rw [ih]
      omega
    · simp [h]
      exact ih

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval countOccurrences 1 []
#eval countOccurrences 1 [1, 1, 1]
#eval countOccurrences 2 [1, 2, 3, 2]
#eval countOccurrences 5 [1, 2, 3]
#eval countOccurrences 0 [0, 1, 0, 1, 0]
#eval countOccurrences 7 [7, 7, 7, 7, 7, 7]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.countOccurrences_correct

