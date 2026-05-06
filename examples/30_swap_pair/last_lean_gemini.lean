import Std

namespace RepoVerifyAutogen

def swapPair (a b : Nat) : Nat × Nat :=
  (b, a)

theorem swapPair_correct (a b : Nat) : swapPair a b = (b, a) := by
  rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval swapPair 0 0
#eval swapPair 1 2
#eval swapPair 7 3
#eval swapPair 42 0
#eval swapPair 5 5
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.swapPair_correct

