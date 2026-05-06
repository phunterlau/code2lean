namespace RepoVerifyAutogen

def square (n : Nat) : Nat :=
  n * n

theorem square_correct (n : Nat) : square n = n * n := by
  rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval square 0
#eval square 1
#eval square 2
#eval square 7
#eval square 12
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.square_correct

