import Std

namespace RepoVerifyAutogen

def divmodPair (a b : Nat) : Nat × Nat :=
  if b = 0 then
    (0, a)
  else
    (a / b, a % b)

theorem divmodPair_correct (a b : Nat) :
  (divmodPair a b).1 * b + (divmodPair a b).2 = a := by
  unfold divmodPair
  by_cases h : b = 0
  · simp [h]
  · simp [h]
    rw [Nat.mul_comm (a / b) b]
    exact Nat.div_add_mod a b

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval divmodPair 0 0
#eval divmodPair 7 0
#eval divmodPair 7 3
#eval divmodPair 12 4
#eval divmodPair 14 5
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.divmodPair_correct

