namespace RepoVerifyAutogen

def divmodPair (a : Int) (b : Int) : Int × Int :=
  if b = 0 then (0, a) else (a / b, a % b)

theorem divmodPair_correct (a b : Int) :
    divmodPair a b = if b = 0 then (0, a) else (a / b, a % b) := by
  unfold divmodPair
  rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval divmodPair 0 0
#eval divmodPair 7 0
#eval divmodPair 7 3
#eval divmodPair 12 4
#eval divmodPair 14 5
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.divmodPair_correct

