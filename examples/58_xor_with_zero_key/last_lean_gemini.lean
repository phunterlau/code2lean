import Std

namespace RepoVerifyAutogen

def xorWithZeroKey (data : List Nat) : List Nat :=
  data.map (fun b => b ^^^ 0)

theorem xorWithZeroKey_correct (data : List Nat) : xorWithZeroKey data = data := by
  induction data with
  | nil => rfl
  | cons hd tl ih =>
    unfold xorWithZeroKey at *
    simp [ih]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval xorWithZeroKey []
#eval xorWithZeroKey [0]
#eval xorWithZeroKey [1, 2, 3]
#eval xorWithZeroKey [255, 0, 128]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.xorWithZeroKey_correct

