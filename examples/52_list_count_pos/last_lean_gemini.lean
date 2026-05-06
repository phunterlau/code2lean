import Std

namespace RepoVerifyAutogen

def listCountPos : List Int → Nat
  | [] => 0
  | x :: xs => (if x > 0 then 1 else 0) + listCountPos xs

theorem listCountPos_le_length (xs : List Int) : listCountPos xs ≤ xs.length := by
  induction xs with
  | nil =>
    simp [listCountPos]
  | cons x xs ih =>
    simp [listCountPos]
    split
    · omega
    · omega

theorem listCountPos_correct (xs ys : List Int) : listCountPos (xs ++ ys) = listCountPos xs + listCountPos ys := by
  induction xs with
  | nil =>
    simp [listCountPos]
  | cons x xs ih =>
    simp [listCountPos, ih]
    omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listCountPos []
#eval listCountPos [0]
#eval listCountPos [1]
#eval listCountPos [0, 1, 2, 0]
#eval listCountPos [3, 2, 1]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listCountPos_correct

