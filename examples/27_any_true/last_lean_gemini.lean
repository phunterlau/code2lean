import Std

namespace RepoVerifyAutogen

def anyTrue : List Bool → Bool
  | [] => false
  | x :: xs => x || anyTrue xs

theorem anyTrue_correct (xs : List Bool) : anyTrue xs = true ↔ true ∈ xs := by
  induction xs with
  | nil => simp [anyTrue]
  | cons x xs ih =>
    cases x with
    | false => simp [anyTrue, ih]
    | true => simp [anyTrue]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval anyTrue []
#eval anyTrue [false]
#eval anyTrue [true]
#eval anyTrue [false, false, true]
#eval anyTrue [false, false]
#eval anyTrue [true, false, true]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.anyTrue_correct

