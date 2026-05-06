namespace RepoVerifyAutogen

def sameLength (a b : List Nat) : Bool :=
  a.length == b.length

theorem sameLength_correct (a b : List Nat) :
  sameLength a b = true ↔ a.length = b.length :=
  beq_iff_eq

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval sameLength [] []
#eval sameLength [1] [2]
#eval sameLength [1] []
#eval sameLength [] [2]
#eval sameLength [1, 2] [3, 4]
#eval sameLength [1, 2] [3]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.sameLength_correct

