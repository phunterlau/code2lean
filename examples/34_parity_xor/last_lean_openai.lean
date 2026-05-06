import Std

namespace RepoVerifyAutogen

def parityXor (a b : Nat) : Bool :=
  decide ((a % 2) ≠ (b % 2))

def isOdd (n : Nat) : Prop :=
  n % 2 = 1

theorem mod_two_eq_zero_or_one (n : Nat) : n % 2 = 0 ∨ n % 2 = 1 := by
  have hlt : n % 2 < 2 := Nat.mod_lt n (by decide)
  omega

theorem parityXor_correct (a b : Nat) :
    parityXor a b = true ↔
      ((isOdd a ∧ ¬ isOdd b) ∨ (¬ isOdd a ∧ isOdd b)) := by
  unfold parityXor
  unfold isOdd
  have ha : a % 2 = 0 ∨ a % 2 = 1 := mod_two_eq_zero_or_one a
  have hb : b % 2 = 0 ∨ b % 2 = 1 := mod_two_eq_zero_or_one b
  cases ha with
  | inl ha0 =>
      cases hb with
      | inl hb0 =>
          simp [ha0, hb0]
      | inr hb1 =>
          simp [ha0, hb1]
  | inr ha1 =>
      cases hb with
      | inl hb0 =>
          simp [ha1, hb0]
      | inr hb1 =>
          simp [ha1, hb1]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval parityXor 0 0
#eval parityXor 0 1
#eval parityXor 1 0
#eval parityXor 1 1
#eval parityXor 8 9
#eval parityXor 12 20
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.parityXor_correct

