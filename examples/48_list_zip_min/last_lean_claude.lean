import Std

namespace RepoVerifyAutogen

def listZipMin : List Int → List Int → List Int
  | [], _ => []
  | _, [] => []
  | x :: xs, y :: ys =>
      (if x < y then x else y) :: listZipMin xs ys

theorem listZipMin_length (xs ys : List Int) :
    (listZipMin xs ys).length = min xs.length ys.length := by
  induction xs generalizing ys with
  | nil => simp [listZipMin]
  | cons x xs ih =>
    cases ys with
    | nil => simp [listZipMin]
    | cons y ys =>
      simp [listZipMin, ih ys, Nat.succ_min_succ]

theorem listZipMin_correct (xs ys : List Int) :
    (listZipMin xs ys).length = min xs.length ys.length :=
  listZipMin_length xs ys

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listZipMin [] []
#eval listZipMin [1] []
#eval listZipMin [] [2]
#eval listZipMin [1, 5, 3] [2, 4, 6]
#eval listZipMin [9, 8] [1, 2, 3]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listZipMin_correct

