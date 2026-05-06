import Std

namespace RepoVerifyAutogen

def powModSmall (a b m : Nat) : Nat :=
  if m = 0 then
    0
  else
    match b with
    | 0 => 1
    | Nat.succ n => (a ^ Nat.succ n) % m

theorem powModSmall_correct (a b m : Nat) :
    powModSmall a b m =
      if m = 0 then
        0
      else if b = 0 then
        1
      else
        (a ^ b) % m := by
  by_cases hm : m = 0
  · simp [powModSmall, hm]
  · cases b with
    | zero =>
        simp [powModSmall, hm]
    | succ n =>
        simp [powModSmall, hm]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval powModSmall 2 0 5
#eval powModSmall 2 3 5
#eval powModSmall 3 4 7
#eval powModSmall 10 2 6
#eval powModSmall 5 3 0
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.powModSmall_correct

