import Std

namespace RepoVerifyAutogen

def parityXor (a b : Int) : Bool :=
  decide (a % 2 ≠ b % 2)

theorem parityXor_correct (a b : Int) :
    parityXor a b = true ↔ a % 2 ≠ b % 2 := by
  unfold parityXor
  simp

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval parityXor 0 0
#eval parityXor 0 1
#eval parityXor 1 0
#eval parityXor 1 1
#eval parityXor 8 9
#eval parityXor 12 20
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.parityXor_correct

