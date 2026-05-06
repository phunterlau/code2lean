import Std

namespace RepoVerifyAutogen

def safeDiv (a b : Nat) : Option Nat :=
  if b = 0 then
    none
  else
    some (a / b)

theorem safeDiv_correct (a b : Nat) :
  (b = 0 ↔ safeDiv a b = none) ∧
  (b ≠ 0 ↔ safeDiv a b = some (a / b)) := by
  cases b
  · simp [safeDiv]
  · simp [safeDiv]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval safeDiv 0 0
#eval safeDiv 7 0
#eval safeDiv 8 2
#eval safeDiv 7 3
#eval safeDiv 15 5
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.safeDiv_correct

