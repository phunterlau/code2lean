import Std

namespace RepoVerifyAutogen

def listZipMin : List Int → List Int → List Int
  | [], _ => []
  | _::_, [] => []
  | x::xs, y::ys => (if x < y then x else y) :: listZipMin xs ys

theorem listZipMin_correct (xs ys : List Int) : listZipMin xs ys = listZipMin ys xs := by
  induction xs generalizing ys with
  | nil =>
    cases ys <;> rfl
  | cons x xs ih =>
    cases ys with
    | nil => rfl
    | cons y ys =>
      unfold listZipMin
      have h_eq : (if x < y then x else y) = (if y < x then y else x) := by
        by_cases c1 : x < y
        · have c2 : ¬ (y < x) := by omega
          simp [c1, c2]
        · by_cases c2 : y < x
          · simp [c1, c2]
          · have eq : x = y := by omega
            subst eq
            rfl
      rw [h_eq, ih ys]

theorem listZipMin_idem (xs : List Int) : listZipMin xs xs = xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    unfold listZipMin
    have c : ¬ (x < x) := by omega
    simp [c, ih]

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

