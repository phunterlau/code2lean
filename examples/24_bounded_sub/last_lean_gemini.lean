import Std

namespace RepoVerifyAutogen

def boundedSub (a b : Nat) : Nat :=
  if a < b then
    0
  else
    a - b

theorem boundedSub_correct (a b : Nat) : boundedSub a b = a - b := by
  unfold boundedSub
  split
  · omega
  · rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval boundedSub 0 0
#eval boundedSub 5 0
#eval boundedSub 0 5
#eval boundedSub 9 4
#eval boundedSub 4 9
#eval boundedSub 42 42
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.boundedSub_correct

