import Std

namespace RepoVerifyAutogen

def byteSum : List Nat → Nat
  | [] => 0
  | x :: xs => x + byteSum xs

theorem byteSum_correct (xs ys : List Nat) : byteSum (xs ++ ys) = byteSum xs + byteSum ys := by
  induction xs with
  | nil => exact (Nat.zero_add _).symm
  | cons x xs ih =>
    calc
      byteSum ((x :: xs) ++ ys) = x + byteSum (xs ++ ys) := rfl
      _ = x + (byteSum xs + byteSum ys) := by rw [ih]
      _ = (x + byteSum xs) + byteSum ys := by omega
      _ = byteSum (x :: xs) + byteSum ys := rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval byteSum []
#eval byteSum [0]
#eval byteSum [1, 2, 3]
#eval byteSum [255]
#eval byteSum [16, 32]
#eval byteSum [5, 5, 5, 5]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.byteSum_correct

