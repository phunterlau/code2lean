import Std

namespace RepoVerifyAutogen

def parityXor (a b : Nat) : Bool :=
  (a % 2) != (b % 2)

theorem parityXor_correct (a b : Nat) :
  parityXor a b = true ↔ (a % 2 = 1 ∧ b % 2 = 0) ∨ (a % 2 = 0 ∧ b % 2 = 1) := by
  unfold parityXor
  have ha : a % 2 = 0 ∨ a % 2 = 1 := by omega
  have hb : b % 2 = 0 ∨ b % 2 = 1 := by omega
  cases ha with
  | inl ha0 =>
    cases hb with
    | inl hb0 =>
      rw [ha0, hb0]
      decide
    | inr hb1 =>
      rw [ha0, hb1]
      decide
  | inr ha1 =>
    cases hb with
    | inl hb0 =>
      rw [ha1, hb0]
      decide
    | inr hb1 =>
      rw [ha1, hb1]
      decide

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

