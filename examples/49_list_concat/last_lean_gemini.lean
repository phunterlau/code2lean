import Std

namespace RepoVerifyAutogen

def listConcat (xs : List Int) (ys : List Int) : List Int :=
  xs ++ ys

theorem listConcat_correct (xs ys : List Int) : listConcat xs ys = xs ++ ys := by
  rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listConcat [] []
#eval listConcat [1] []
#eval listConcat [] [2]
#eval listConcat [1, 2] [3, 4]
#eval listConcat [0, 0] [1]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listConcat_correct

