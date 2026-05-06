import Std

namespace RepoVerifyAutogen

def clampInt (x lo hi : Int) : Int :=
  if x < lo then lo
  else if hi < x then hi
  else x

theorem clampInt_correct (x lo hi : Int) (h : lo ≤ hi) :
  lo ≤ clampInt x lo hi ∧
  clampInt x lo hi ≤ hi ∧
  (x < lo → clampInt x lo hi = lo) ∧
  (hi < x → clampInt x lo hi = hi) ∧
  (lo ≤ x ∧ x ≤ hi → clampInt x lo hi = x) := by
  unfold clampInt
  by_cases h1 : x < lo
  · simp [h1]
    omega
  · simp [h1]
    by_cases h2 : hi < x
    · simp [h2]
      omega
    · simp [h2]
      omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval clampInt 5 0 10
#eval clampInt (-1) 0 10
#eval clampInt 100 0 10
#eval clampInt (-50) (-10) 10
#eval clampInt 7 (-10) 10
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.clampInt_correct

