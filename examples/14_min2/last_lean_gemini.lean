import Std

namespace RepoVerifyAutogen

def min2 (a b : Nat) : Nat :=
  if a < b then
    a
  else
    b

theorem min2_correct (a b : Nat) : min2 a b ≤ a ∧ min2 a b ≤ b ∧ (min2 a b = a ∨ min2 a b = b) := by
  unfold min2
  by_cases h : a < b
  · simp [h]
    omega
  · simp [h]
    omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval min2 0 0
#eval min2 1 0
#eval min2 0 1
#eval min2 7 3
#eval min2 3 7
#eval min2 42 42
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.min2_correct

