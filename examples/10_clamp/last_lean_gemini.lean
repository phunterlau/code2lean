import Std

namespace RepoVerifyAutogen

def clamp (x lo hi : Int) : Int :=
  if x < lo then
    lo
  else if hi < x then
    hi
  else
    x

theorem clamp_correct (x lo hi : Int) (h : lo ≤ hi) :
  lo ≤ clamp x lo hi ∧
  clamp x lo hi ≤ hi ∧
  (x < lo → clamp x lo hi = lo) ∧
  (hi < x → clamp x lo hi = hi) ∧
  (lo ≤ x ∧ x ≤ hi → clamp x lo hi = x) := by
  unfold clamp
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
#eval clamp 5 0 10
#eval clamp (-1) 0 10
#eval clamp 100 0 10
#eval clamp 0 0 10
#eval clamp 10 0 10
#eval clamp (-50) (-10) 10
#eval clamp 7 (-10) 10
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.clamp_correct

