import Std

namespace RepoVerifyAutogen

def bitCount8Aux : Nat → Nat → Nat
  | 0, _ => 0
  | k+1, n => (n % 2) + bitCount8Aux k (n / 2)

def bitCount8 (n : Nat) : Nat := bitCount8Aux 8 n

theorem bitCount8Aux_le (k n : Nat) : bitCount8Aux k n ≤ k := by
  induction k generalizing n with
  | zero => simp [bitCount8Aux]
  | succ k ih =>
    unfold bitCount8Aux
    have h1 : n % 2 ≤ 1 := by omega
    have h2 := ih (n / 2)
    omega

theorem bitCount8_correct (n : Nat) : bitCount8 n ≤ 8 := by
  unfold bitCount8
  exact bitCount8Aux_le 8 n

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval bitCount8 0
#eval bitCount8 1
#eval bitCount8 3
#eval bitCount8 15
#eval bitCount8 128
#eval bitCount8 255
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.bitCount8_correct

