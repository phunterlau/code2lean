import Std

namespace RepoVerifyAutogen

def countAfterIncrementAux : List Int → Nat → Nat → Bool
| [], b, a => decide (b ≤ a)
| x :: xs, b, a =>
  countAfterIncrementAux xs (if x > 0 then b + 1 else b) (if x + 1 > 0 then a + 1 else a)

def countAfterIncrement (xs : List Int) : Bool :=
  countAfterIncrementAux xs 0 0

theorem countAfterIncrementAux_correct (xs : List Int) (b a : Nat) (h : b ≤ a) :
    countAfterIncrementAux xs b a = true := by
  induction xs generalizing b a with
  | nil =>
    unfold countAfterIncrementAux
    exact decide_eq_true h
  | cons x xs ih =>
    unfold countAfterIncrementAux
    refine ih _ _ ?_
    by_cases h1 : x > 0
    · by_cases h2 : x + 1 > 0
      · simp [h1, h2]; omega
      · simp [h1, h2]; omega
    · by_cases h2 : x + 1 > 0
      · simp [h1, h2]; omega
      · simp [h1, h2]; omega

theorem countAfterIncrement_correct (xs : List Int) : countAfterIncrement xs = true := by
  unfold countAfterIncrement
  refine countAfterIncrementAux_correct xs 0 0 ?_
  omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval countAfterIncrement []
#eval countAfterIncrement [0]
#eval countAfterIncrement [1, 2, 3]
#eval countAfterIncrement [0, 1, 0]
#eval countAfterIncrement [5, 0, 7]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.countAfterIncrement_correct

