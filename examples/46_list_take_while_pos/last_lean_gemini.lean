import Std

namespace RepoVerifyAutogen

def listTakeWhilePos : List Nat → List Nat
  | [] => []
  | x :: xs => if x == 0 then [] else x :: listTakeWhilePos xs

theorem listTakeWhilePos_correct (xs : List Nat) :
  listTakeWhilePos xs = xs.takeWhile (fun a => !(a == 0)) := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    cases h : x == 0 <;> simp [listTakeWhilePos, List.takeWhile, ih, h]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listTakeWhilePos []
#eval listTakeWhilePos [0]
#eval listTakeWhilePos [1, 2, 0, 3]
#eval listTakeWhilePos [5, 4, 3]
#eval listTakeWhilePos [0, 1, 2]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listTakeWhilePos_correct

