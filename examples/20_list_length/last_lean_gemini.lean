import Std

namespace RepoVerifyAutogen

def listLengthAux (xs : List Int) (n : Nat) : Nat :=
  match xs with
  | [] => n
  | _ :: t => listLengthAux t (n + 1)

def listLength (xs : List Int) : Nat :=
  listLengthAux xs 0

theorem listLengthAux_correct (xs : List Int) (n : Nat) : listLengthAux xs n = xs.length + n := by
  induction xs generalizing n with
  | nil =>
    simp [listLengthAux]
  | cons hd tl ih =>
    simp [listLengthAux]
    rw [ih]
    omega

theorem listLength_correct (xs : List Int) : listLength xs = xs.length := by
  simp [listLength]
  rw [listLengthAux_correct]
  omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listLength []
#eval listLength [1]
#eval listLength [1, 2]
#eval listLength [5, 4, 3, 2, 1]
#eval listLength [0, 0, 0, 0]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listLength_correct

