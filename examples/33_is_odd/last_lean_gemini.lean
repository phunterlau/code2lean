import Std

namespace RepoVerifyAutogen

def isOdd (n : Nat) : Bool :=
  n % 2 == 1

theorem isOdd_correct (n : Nat) : isOdd n = true ↔ n % 2 = 1 := by
  unfold isOdd
  exact beq_iff_eq

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval isOdd 0
#eval isOdd 1
#eval isOdd 2
#eval isOdd 7
#eval isOdd 8
#eval isOdd 255
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.isOdd_correct

