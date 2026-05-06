import Std

namespace RepoVerifyAutogen

def gcdTwo (a b : Nat) : Nat :=
  if _h : b = 0 then
    a
  else
    gcdTwo b (a % b)
termination_by b
decreasing_by
  apply Nat.mod_lt
  omega

theorem gcdTwo_correct (a b : Nat) : gcdTwo a b = Nat.gcd a b :=
  if h : b = 0 then by
    unfold gcdTwo
    rw [dif_pos h]
    rw [h]
    rw [Nat.gcd_zero_right]
  else by
    unfold gcdTwo
    rw [dif_neg h]
    rw [gcdTwo_correct b (a % b)]
    rw [Nat.gcd_comm a b]
    rw [Nat.gcd_rec b a]
    rw [Nat.gcd_comm (a % b) b]
termination_by b
decreasing_by
  apply Nat.mod_lt
  omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval gcdTwo 0 0
#eval gcdTwo 12 0
#eval gcdTwo 0 9
#eval gcdTwo 12 8
#eval gcdTwo 21 14
#eval gcdTwo 17 13
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.gcdTwo_correct

