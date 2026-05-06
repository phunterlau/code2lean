import Std

namespace RepoVerifyAutogen

def powModSmallLoop (a m : Nat) : Nat → Nat → Nat
  | 0, acc => acc
  | b + 1, acc => powModSmallLoop a m b ((acc * a) % m)

def powModSmall (a b m : Nat) : Nat :=
  if m = 0 then 0 else powModSmallLoop a m b 1

theorem mod_mul_mod_left (x y m : Nat) : ((x % m) * y) % m = (x * y) % m := by
  have h1 : ((x % m) * y) % m = ((x % m) % m * (y % m)) % m := Nat.mul_mod (x % m) y m
  have h2 : (x * y) % m = (x % m * (y % m)) % m := Nat.mul_mod x y m
  have h3 : (x % m) % m = x % m := Nat.mod_mod x m
  rw [h3] at h1
  rw [h1, ← h2]

theorem powModSmallLoop_mod (a m b acc : Nat) :
    powModSmallLoop a m b acc % m = (acc * a ^ b) % m := by
  induction b generalizing acc with
  | zero =>
    simp only [powModSmallLoop]
    have h : a ^ 0 = 1 := rfl
    rw [h, Nat.mul_one]
  | succ b ih =>
    simp only [powModSmallLoop]
    rw [ih]
    rw [mod_mul_mod_left]
    have h_pow : a ^ (b + 1) = a ^ b * a := rfl
    rw [h_pow]
    have h_mul : (acc * a) * a ^ b = acc * (a ^ b * a) := by
      rw [Nat.mul_assoc]
      rw [Nat.mul_comm a (a ^ b)]
    rw [h_mul]

theorem powModSmall_correct (a b m : Nat) :
    powModSmall a b m % m = if m = 0 then 0 else (a ^ b) % m := by
  unfold powModSmall
  by_cases h : m = 0
  · simp [h]
  · simp [h]
    have h_loop := powModSmallLoop_mod a m b 1
    rw [Nat.one_mul] at h_loop
    exact h_loop

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval powModSmall 2 0 5
#eval powModSmall 2 3 5
#eval powModSmall 3 4 7
#eval powModSmall 10 2 6
#eval powModSmall 5 3 0
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.powModSmall_correct

