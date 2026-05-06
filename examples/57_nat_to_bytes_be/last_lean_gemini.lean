import Std

namespace RepoVerifyAutogen

def natToBytesBeLoop (n : Nat) (out : List Nat) : List Nat :=
  if h : n = 0 then
    out
  else
    natToBytesBeLoop (n / 256) ((n % 256) :: out)
termination_by n
decreasing_by omega

def natToBytesBe (n : Nat) : List Nat :=
  if n = 0 then [0]
  else natToBytesBeLoop n []

def bytesToNat (acc : Nat) : List Nat → Nat
  | [] => acc
  | x :: xs => bytesToNat (acc * 256 + x) xs

theorem bytesToNat_cons (acc : Nat) (x : Nat) (xs : List Nat) :
  bytesToNat acc (x :: xs) = bytesToNat (acc * 256 + x) xs := rfl

theorem bytesToNat_natToBytesBeLoop (n : Nat) (out : List Nat) :
  bytesToNat 0 (natToBytesBeLoop n out) = bytesToNat n out := by
  unfold natToBytesBeLoop
  split
  · rename_i hn
    subst hn
    rfl
  · rename_i hn
    have ih := bytesToNat_natToBytesBeLoop (n / 256) ((n % 256) :: out)
    rw [ih]
    rw [bytesToNat_cons]
    have h_eq : (n / 256) * 256 + n % 256 = n := by omega
    rw [h_eq]
termination_by n
decreasing_by omega

theorem natToBytesBe_correct (n : Nat) :
  bytesToNat 0 (natToBytesBe n) = n := by
  unfold natToBytesBe
  split
  · rename_i hn
    subst hn
    rfl
  · rename_i hn
    rw [bytesToNat_natToBytesBeLoop]
    rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval natToBytesBe 0
#eval natToBytesBe 1
#eval natToBytesBe 255
#eval natToBytesBe 256
#eval natToBytesBe 258
#eval natToBytesBe 65535
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.natToBytesBe_correct

