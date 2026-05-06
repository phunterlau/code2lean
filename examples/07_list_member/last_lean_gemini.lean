import Std

namespace RepoVerifyAutogen

def listMember (x : Nat) : List Nat → Bool
  | [] => false
  | y :: ys => if x == y then true else listMember x ys

theorem listMember_correct (x : Nat) (xs : List Nat) :
    listMember x xs = true ↔ x ∈ xs := by
  induction xs with
  | nil =>
    unfold listMember
    simp
  | cons y ys ih =>
    unfold listMember
    by_cases hxy : x = y
    · subst hxy
      simp
    · simp [hxy, ih]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listMember 1 []
#eval listMember 1 [1, 2, 3]
#eval listMember 4 [1, 2, 3]
#eval listMember 3 [1, 2, 3]
#eval listMember 0 [0, 0, 0]
#eval listMember 9 [1, 2, 3, 4, 5]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listMember_correct

