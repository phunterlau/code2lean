import Std

namespace RepoVerifyAutogen

def boolToNat (flag : Bool) : Nat :=
  if flag then 1 else 0

theorem boolToNat_correct (flag : Bool) :
  (boolToNat flag = 1 ↔ flag = true) ∧
  (boolToNat flag = 0 ↔ flag = false) := by
  cases flag
  · simp [boolToNat]
  · simp [boolToNat]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval boolToNat true
#eval boolToNat false
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.boolToNat_correct

