import Std

namespace RepoVerifyAutogen

def saturatingAdd8 (a b : Nat) : Nat :=
  if a + b > 255 then
    255
  else
    a + b

theorem saturatingAdd8_correct (a b : Nat) : saturatingAdd8 a b = min (a + b) 255 := by
  unfold saturatingAdd8
  by_cases h : a + b > 255
  · simp [h]
    omega
  · simp [h]
    omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval saturatingAdd8 0 0
#eval saturatingAdd8 1 2
#eval saturatingAdd8 200 20
#eval saturatingAdd8 200 100
#eval saturatingAdd8 255 0
#eval saturatingAdd8 128 127
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.saturatingAdd8_correct

