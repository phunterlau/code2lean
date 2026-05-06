import Std

namespace RepoVerifyAutogen

def listZipMin : List Int → List Int → List Int
  | x :: xs, y :: ys => min x y :: listZipMin xs ys
  | _, _ => []

theorem listZipMin_correct (xs ys : List Int) :
    listZipMin xs ys = List.zipWith (fun x y => min x y) xs ys := by
  induction xs generalizing ys with
  | nil =>
      cases ys with
      | nil => rfl
      | cons y ys => rfl
  | cons x xs ih =>
      cases ys with
      | nil => rfl
      | cons y ys =>
          simp [listZipMin, ih]

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

