import Std

namespace RepoVerifyAutogen

def listDropWhilePos : List Nat → List Nat
  | [] => []
  | x :: xs =>
      if x = 0 then x :: xs else listDropWhilePos xs

theorem listDropWhilePos_correct (xs : List Nat) :
    listDropWhilePos xs = List.dropWhile (fun n : Nat => n != 0) xs := by
  induction xs with
  | nil =>
      rfl
  | cons x xs ih =>
      by_cases h : x = 0
      · simp [listDropWhilePos, h]
      · simp [listDropWhilePos, h, ih]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listDropWhilePos []
#eval listDropWhilePos [0]
#eval listDropWhilePos [1, 2, 0, 3]
#eval listDropWhilePos [5, 4, 3]
#eval listDropWhilePos [0, 1, 2]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listDropWhilePos_correct

