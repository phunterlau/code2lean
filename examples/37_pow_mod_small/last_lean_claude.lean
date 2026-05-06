import Std

namespace RepoVerifyAutogen

def powModSmallAux (a : Nat) (m : Nat) : Nat → Nat
  | 0 => 1 % m
  | n+1 => (powModSmallAux a m n * a) % m

def powModSmall (a b m : Nat) : Nat :=
  if m = 0 then 0 else powModSmallAux a m b

theorem powModSmallAux_lt (a m : Nat) (b : Nat) (hm : m ≠ 0) :
    powModSmallAux a m b < m := by
  induction b with
  | zero =>
    unfold powModSmallAux
    exact Nat.mod_lt _ (Nat.pos_of_ne_zero hm)
  | succ n ih =>
    unfold powModSmallAux
    exact Nat.mod_lt _ (Nat.pos_of_ne_zero hm)

theorem powModSmall_correct (a b m : Nat) : powModSmall a b m < m ∨ (m = 0 ∧ powModSmall a b m = 0) := by
  unfold powModSmall
  by_cases hm : m = 0
  · simp [hm]
  · simp [hm]
    exact powModSmallAux_lt a m b hm

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

