import Std

namespace RepoVerifyAutogen

/-- Compute n! for n >= 0. -/
def factorial : Nat → Nat
  | 0 => 1
  | n + 1 => (n + 1) * factorial n

theorem factorial_correct (n : Nat) : factorial 0 = 1 ∧ factorial (n + 1) = (n + 1) * factorial n := by
  exact ⟨rfl, rfl⟩

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval factorial 0
#eval factorial 1
#eval factorial 2
#eval factorial 5
#eval factorial 6
#eval factorial 8
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.factorial_correct

