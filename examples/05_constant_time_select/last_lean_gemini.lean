import Std

namespace RepoVerifyAutogen

def constantTimeSelect (cond : Bool) (a b : Int) : Int :=
  if cond then a else b

theorem constantTimeSelect_correct (a b : Int) :
  constantTimeSelect true a b = a ∧ constantTimeSelect false a b = b := by
  exact ⟨rfl, rfl⟩

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval constantTimeSelect true 1 2
#eval constantTimeSelect false 1 2
#eval constantTimeSelect true 0 999
#eval constantTimeSelect false 100 200
#eval constantTimeSelect true 42 42
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.constantTimeSelect_correct

