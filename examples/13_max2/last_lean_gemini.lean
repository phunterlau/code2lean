import Std

namespace RepoVerifyAutogen

def max2 (a b : Nat) : Nat :=
  if a < b then b else a

theorem max2_correct (a b : Nat) :
  a ≤ max2 a b ∧ b ≤ max2 a b ∧ (max2 a b = a ∨ max2 a b = b) := by
  unfold max2
  by_cases h : a < b
  · simp [h]
    omega
  · simp [h]
    omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval max2 0 0
#eval max2 1 0
#eval max2 0 1
#eval max2 7 3
#eval max2 3 7
#eval max2 42 42
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.max2_correct

