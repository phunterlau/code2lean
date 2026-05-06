import Std

namespace RepoVerifyAutogen

def allTrue : List Bool → Bool
  | [] => true
  | false :: _ => false
  | true :: xs => allTrue xs

theorem allTrue_correct (xs : List Bool) : allTrue xs = true ↔ ∀ x, x ∈ xs → x = true := by
  induction xs with
  | nil =>
    apply Iff.intro
    · intro h1 x hx
      cases hx
    · intro h1
      rfl
  | cons h t ih =>
    cases h with
    | false =>
      apply Iff.intro
      · intro h1
        cases h1
      · intro h1
        have h2 : false = true := h1 false (List.Mem.head t)
        cases h2
    | true =>
      apply Iff.intro
      · intro h1 x hx
        cases hx
        · rfl
        · apply ih.mp h1
          assumption
      · intro h1
        apply ih.mpr
        intro y hy
        exact h1 y (List.Mem.tail true hy)

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval allTrue []
#eval allTrue [false]
#eval allTrue [true]
#eval allTrue [true, true, true]
#eval allTrue [true, false, true]
#eval allTrue [false, false]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.allTrue_correct

