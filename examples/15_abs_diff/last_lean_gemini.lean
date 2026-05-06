import Std

namespace RepoVerifyAutogen

def absDiff (a b : Int) : Int :=
  if a < b then
    b - a
  else
    a - b

theorem absDiff_correct (a b : Int) :
  0 ≤ absDiff a b ∧
  (absDiff a b = a - b ∨ absDiff a b = b - a) ∧
  absDiff a b = absDiff b a := by
  unfold absDiff
  omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval absDiff 0 0
#eval absDiff 5 0
#eval absDiff 0 5
#eval absDiff 9 4
#eval absDiff 4 9
#eval absDiff 42 42
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.absDiff_correct

