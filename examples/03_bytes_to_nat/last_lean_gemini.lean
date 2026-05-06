import Std

namespace RepoVerifyAutogen

def bytesToNatAux : List Nat → Nat → Nat
  | [], n => n
  | b :: bs, n => bytesToNatAux bs (n * 256 + b)

def bytesToNat (data : List Nat) : Nat :=
  bytesToNatAux data 0

theorem bytesToNatAux_append (l1 l2 : List Nat) (n : Nat) :
  bytesToNatAux (l1 ++ l2) n = bytesToNatAux l2 (bytesToNatAux l1 n) := by
  induction l1 generalizing n with
  | nil => rfl
  | cons b bs ih => exact ih (n * 256 + b)

theorem bytesToNat_empty :
  bytesToNat [] = 0 := rfl

theorem bytesToNat_singleton (b : Nat) :
  bytesToNat [b] = b :=
  Nat.zero_add b

theorem bytesToNat_correct (data : List Nat) (b : Nat) :
  bytesToNat (data ++ [b]) = bytesToNat data * 256 + b :=
  bytesToNatAux_append data [b] 0

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval bytesToNat []
#eval bytesToNat [0]
#eval bytesToNat [1]
#eval bytesToNat [255]
#eval bytesToNat [1, 0]
#eval bytesToNat [1, 2, 3]
#eval bytesToNat [255, 255]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.bytesToNat_correct

