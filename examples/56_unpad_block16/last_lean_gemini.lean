import Std

namespace RepoVerifyAutogen

def unpadBlock16 (data : List Nat) : List Nat :=
  if data.length = 0 then
    []
  else if (data.getLast?).getD 0 = 0 ∨ (data.getLast?).getD 0 > data.length then
    data
  else
    data.take (data.length - (data.getLast?).getD 0)

theorem length_take_le_l (n : Nat) (l : List Nat) : (l.take n).length ≤ l.length := by
  revert l
  induction n with
  | zero =>
    intro l
    exact Nat.zero_le _
  | succ n ih =>
    intro l
    cases l with
    | nil => exact Nat.zero_le _
    | cons hd tl => exact Nat.succ_le_succ (ih tl)

theorem unpadBlock16_correct (data : List Nat) :
    (unpadBlock16 data).length ≤ data.length := by
  unfold unpadBlock16
  split
  · exact Nat.zero_le _
  · split
    · exact Nat.le_refl _
    · exact length_take_le_l _ _

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval unpadBlock16 []
#eval unpadBlock16 [1]
#eval unpadBlock16 [5, 1]
#eval unpadBlock16 [5, 2, 2]
#eval unpadBlock16 [5, 0]
#eval unpadBlock16 [5, 9]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.unpadBlock16_correct

