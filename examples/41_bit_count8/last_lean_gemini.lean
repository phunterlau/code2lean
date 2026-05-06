import Std

namespace RepoVerifyAutogen

def bitCountLoop : Nat → Nat → Nat → Nat
  | _, count, 0 => count
  | n, count, i + 1 => bitCountLoop (n / 2) (count + n % 2) i

def bitCount8 (n : Nat) : Nat := bitCountLoop n 0 8

theorem bitCountLoop_le (n count i : Nat) : bitCountLoop n count i ≤ count + i := by
  induction i generalizing n count with
  | zero =>
    unfold bitCountLoop
    omega
  | succ i ih =>
    unfold bitCountLoop
    have h1 : n % 2 ≤ 1 := by omega
    have h2 := ih (n / 2) (count + n % 2)
    omega

theorem bitCount8_correct (n : Nat) : bitCount8 n ≤ 8 := by
  unfold bitCount8
  have h := bitCountLoop_le n 0 8
  omega

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

