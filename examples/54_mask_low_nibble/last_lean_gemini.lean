import Std

namespace RepoVerifyAutogen

def maskLowNibble (b : Nat) : Nat :=
  b % 16

theorem maskLowNibble_correct (b : Nat) : maskLowNibble b < 16 := by
  unfold maskLowNibble
  omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval maskLowNibble 0
#eval maskLowNibble 15
#eval maskLowNibble 16
#eval maskLowNibble 31
#eval maskLowNibble 255
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.maskLowNibble_correct

