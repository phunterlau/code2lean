import Std

namespace RepoVerifyAutogen

def listSumLoop : List Int → Int → Int
| [], total => total
| x :: xs, total => listSumLoop xs (total + x)

def listSum (xs : List Int) : Int :=
  listSumLoop xs 0

def specSum : List Int → Int
| [] => 0
| x :: xs => x + specSum xs

theorem listSumLoop_eq (xs : List Int) (total : Int) :
  listSumLoop xs total = total + specSum xs := by
  induction xs generalizing total with
  | nil =>
    unfold listSumLoop
    unfold specSum
    omega
  | cons x xs ih =>
    unfold listSumLoop
    unfold specSum
    rw [ih (total + x)]
    omega

theorem listSum_correct (xs : List Int) :
  listSum xs = specSum xs := by
  unfold listSum
  rw [listSumLoop_eq]
  omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listSum []
#eval listSum [0]
#eval listSum [1, 2, 3]
#eval listSum [5, 5, 5]
#eval listSum [10, 0, 1]
#eval listSum [9, 8, 7, 6]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listSum_correct

