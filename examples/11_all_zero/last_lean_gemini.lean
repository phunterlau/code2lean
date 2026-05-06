import Std

namespace RepoVerifyAutogen

def allZero : List Nat → Bool
| [] => true
| 0 :: bs => allZero bs
| (Nat.succ n) :: bs => false

theorem allZero_correct (data : List Nat) :
  allZero data = true ↔ ∀ x ∈ data, x = 0 := by
  induction data with
  | nil =>
    simp [allZero]
  | cons b bs ih =>
    cases b with
    | zero =>
      simp [allZero, ih]
    | succ n =>
      simp [allZero]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval allZero []
#eval allZero [0]
#eval allZero [0, 0, 0]
#eval allZero [1]
#eval allZero [0, 2, 0]
#eval allZero [255]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.allZero_correct

