import Std

namespace RepoVerifyAutogen

def bitCountLoop : Nat → Nat → Nat
  | 0, _ => 0
  | Nat.succ k, n => n % 2 + bitCountLoop k (n / 2)

def bitCount8 (n : Nat) : Nat :=
  bitCountLoop 8 n

def natListSum : List Nat → Nat
  | [] => 0
  | x :: xs => x + natListSum xs

def low8Bits (n : Nat) : List Nat :=
  let n0 := n
  let n1 := n0 / 2
  let n2 := n1 / 2
  let n3 := n2 / 2
  let n4 := n3 / 2
  let n5 := n4 / 2
  let n6 := n5 / 2
  let n7 := n6 / 2
  [n0 % 2, n1 % 2, n2 % 2, n3 % 2, n4 % 2, n5 % 2, n6 % 2, n7 % 2]

def low8BitCount (n : Nat) : Nat :=
  natListSum (low8Bits n)

theorem bitCount8_eq_low8BitCount (n : Nat) :
    bitCount8 n = low8BitCount n := by
  simp [bitCount8, low8BitCount, low8Bits, natListSum, bitCountLoop]

theorem bitCountLoop_le (k n : Nat) :
    bitCountLoop k n ≤ k := by
  induction k generalizing n with
  | zero =>
      simp [bitCountLoop]
  | succ k ih =>
      unfold bitCountLoop
      have hbit : n % 2 < 2 := Nat.mod_lt n (by decide)
      have htail : bitCountLoop k (n / 2) ≤ k := ih (n / 2)
      omega

theorem bitCount8_correct (n : Nat) :
    bitCount8 n = low8BitCount n ∧ bitCount8 n ≤ 8 := by
  refine And.intro ?eq ?bound
  · exact bitCount8_eq_low8BitCount n
  · unfold bitCount8
    exact bitCountLoop_le 8 n

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

