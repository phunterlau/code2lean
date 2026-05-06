import Std

namespace RepoVerifyAutogen

def padToBlock16 (data : List Nat) : List Nat :=
  let padLen := 16 - (data.length % 16)
  data ++ List.replicate padLen padLen

theorem padToBlock16_correct (data : List Nat) : 
  (padToBlock16 data).length % 16 = 0 ∧ 
  (padToBlock16 data).length > data.length ∧ 
  (padToBlock16 data).length - data.length ≤ 16 := by
  unfold padToBlock16
  simp
  omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval padToBlock16 []
#eval padToBlock16 [1]
#eval padToBlock16 [1, 2, 3]
#eval padToBlock16 [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
#eval padToBlock16 [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.padToBlock16_correct

