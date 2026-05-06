import Std

namespace RepoVerifyAutogen

def firstByteOrZero (data : List Nat) : Nat :=
  match data with
  | [] => 0
  | x :: _ => x

theorem firstByteOrZero_correct (data : List Nat) :
  firstByteOrZero data = (data.head?).getD 0 := by
  cases data
  · rfl
  · rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval firstByteOrZero []
#eval firstByteOrZero [0]
#eval firstByteOrZero [5]
#eval firstByteOrZero [9, 8, 7]
#eval firstByteOrZero [255, 0]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.firstByteOrZero_correct

