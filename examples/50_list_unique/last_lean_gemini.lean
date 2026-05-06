import Std

namespace RepoVerifyAutogen

def listUniqueAux (xs : List Nat) (out : List Nat) : List Nat :=
  match xs with
  | [] => out
  | x :: tail =>
    if x ∈ out then
      listUniqueAux tail out
    else
      listUniqueAux tail (out ++ [x])

def listUnique (xs : List Nat) : List Nat :=
  listUniqueAux xs []

theorem listUniqueAux_mem (xs out : List Nat) (y : Nat) :
  y ∈ listUniqueAux xs out ↔ y ∈ xs ∨ y ∈ out := by
  induction xs generalizing out with
  | nil =>
    simp [listUniqueAux]
  | cons x xs ih =>
    by_cases h : x ∈ out
    · simp [listUniqueAux, h]
      rw [ih out]
      by_cases hy : y = x
      · subst hy
        simp [h]
      · simp [hy]
    · simp [listUniqueAux, h]
      rw [ih (out ++ [x])]
      by_cases hy : y = x
      · subst hy
        simp
      · simp [hy]

theorem listUnique_correct (xs : List Nat) (y : Nat) :
  y ∈ listUnique xs ↔ y ∈ xs := by
  unfold listUnique
  rw [listUniqueAux_mem]
  simp

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listUnique []
#eval listUnique [1]
#eval listUnique [1, 1, 1]
#eval listUnique [1, 2, 1, 3, 2]
#eval listUnique [0, 1, 0, 2]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listUnique_correct

