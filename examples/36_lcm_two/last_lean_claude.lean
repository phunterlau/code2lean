import Std

namespace RepoVerifyAutogen

def gcdNat (x y : Nat) : Nat := Nat.gcd x y

def lcmTwo (a b : Nat) : Nat :=
  if a = 0 ∨ b = 0 then 0
  else (a / Nat.gcd a b) * b

theorem lcmTwo_zero_left (b : Nat) : lcmTwo 0 b = 0 := by
  unfold lcmTwo
  simp

theorem lcmTwo_zero_right (a : Nat) : lcmTwo a 0 = 0 := by
  unfold lcmTwo
  simp

theorem lcmTwo_correct (a b : Nat) :
    lcmTwo a b = if a = 0 ∨ b = 0 then 0 else (a / Nat.gcd a b) * b := by
  unfold lcmTwo
  rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval lcmTwo 0 0
#eval lcmTwo 0 5
#eval lcmTwo 4 6
#eval lcmTwo 7 3
#eval lcmTwo 12 8
#eval lcmTwo 9 9
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.lcmTwo_correct

