import Std

namespace RepoVerifyAutogen

def isEven (n : Nat) : Bool :=
  n % 2 == 0

theorem isEven_correct (n : Nat) : isEven n = true ↔ n % 2 = 0 := by
  unfold isEven
  cases n % 2 with
  | zero => simp
  | succ m => simp

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval isEven 0
#eval isEven 1
#eval isEven 2
#eval isEven 7
#eval isEven 8
#eval isEven 255
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.isEven_correct

