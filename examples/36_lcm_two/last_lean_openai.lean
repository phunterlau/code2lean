import Std

namespace RepoVerifyAutogen

def gcdTwo (x y : Nat) : Nat :=
  Nat.gcd x y

def lcmTwo (a b : Nat) : Nat :=
  if a = 0 ∨ b = 0 then
    0
  else
    (a / gcdTwo a b) * b

theorem lcmTwo_correct (a b : Nat) : lcmTwo a b = Nat.lcm a b := by
  unfold lcmTwo gcdTwo
  by_cases h : a = 0 ∨ b = 0
  · cases h with
    | inl ha =>
        subst a
        simp [Nat.lcm]
    | inr hb =>
        subst b
        simp [Nat.lcm]
  · rw [if_neg h]
    simp only [Nat.lcm]
    calc
      a / Nat.gcd a b * b = b * (a / Nat.gcd a b) := by
        rw [Nat.mul_comm]
      _ = b * a / Nat.gcd a b := by
        exact (Nat.mul_div_assoc b (Nat.gcd_dvd_left a b)).symm
      _ = a * b / Nat.gcd a b := by
        rw [Nat.mul_comm b a]

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

