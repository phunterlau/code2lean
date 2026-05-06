namespace RepoVerifyAutogen

def maskHighBit (b : Nat) : Nat :=
  b % 128

theorem maskHighBit_correct (b : Nat) : maskHighBit b < 128 ∧ (b < 128 → maskHighBit b = b) := by
  unfold maskHighBit
  omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval maskHighBit 0
#eval maskHighBit 1
#eval maskHighBit 127
#eval maskHighBit 128
#eval maskHighBit 255
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.maskHighBit_correct

