import Std

namespace RepoVerifyAutogen

def saturatingAdd8NoClamp (a b : Nat) : Nat :=
  let total := a + b
  if total > 255 then
    255
  else
    total

theorem saturatingAdd8NoClamp_correct (a b : Nat) :
    saturatingAdd8NoClamp a b = Nat.min (a + b) 255 := by
  unfold saturatingAdd8NoClamp
  by_cases h : a + b > 255
  · simp [h, Nat.min_eq_right (show 255 ≤ a + b by omega)]
  · simp [h, Nat.min_eq_left (show a + b ≤ 255 by omega)]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval saturatingAdd8NoClamp 0 0
#eval saturatingAdd8NoClamp 1 2
#eval saturatingAdd8NoClamp 200 20
#eval saturatingAdd8NoClamp 200 100
#eval saturatingAdd8NoClamp 255 0
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.saturatingAdd8NoClamp_correct

