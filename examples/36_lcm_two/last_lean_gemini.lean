import Std

namespace RepoVerifyAutogen

def gcd_helper (x y : Nat) : Nat :=
  if h : y = 0 then
    x
  else
    gcd_helper y (x % y)
termination_by y
decreasing_by
  have h_pos : 0 < y := by omega
  exact Nat.mod_lt x h_pos

def lcmTwo (a b : Nat) : Nat :=
  if a = 0 ∨ b = 0 then
    0
  else
    (a / gcd_helper a b) * b

theorem gcd_helper_one_right (a : Nat) : gcd_helper a 1 = 1 := by
  rw [gcd_helper]
  have h_mod : a % 1 = 0 := by omega
  simp [h_mod]
  rw [gcd_helper]
  simp

theorem gcd_helper_one_left (a : Nat) (h : a ≠ 0) : gcd_helper 1 a = 1 := by
  by_cases h2 : a = 1
  · subst h2
    exact gcd_helper_one_right 1
  · rw [gcd_helper]
    have h_mod : 1 % a = 1 := Nat.mod_eq_of_lt (by omega)
    simp [h, h_mod]
    exact gcd_helper_one_right a

theorem lcmTwo_correct (a : Nat) :
  lcmTwo a 0 = 0 ∧
  lcmTwo 0 a = 0 ∧
  lcmTwo a 1 = a ∧
  lcmTwo 1 a = a := by
  constructor
  · rw [lcmTwo]
    simp
  · constructor
    · rw [lcmTwo]
      simp
    · constructor
      · rw [lcmTwo]
        by_cases h : a = 0
        · simp [h]
        · simp [h]
          rw [gcd_helper_one_right a]
          simp
      · rw [lcmTwo]
        by_cases h : a = 0
        · simp [h]
        · simp [h]
          rw [gcd_helper_one_left a h]
          simp

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

