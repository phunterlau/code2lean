import Std

namespace RepoVerifyAutogen

def insecureCompareLoop : List Nat → List Nat → Bool
| [], [] => true
| x::xs, y::ys => if x = y then insecureCompareLoop xs ys else false
| _, _ => false

theorem insecureCompareLoop_correct (expected supplied : List Nat) :
  insecureCompareLoop expected supplied = true ↔ expected = supplied := by
  induction expected generalizing supplied with
  | nil =>
    cases supplied with
    | nil => simp [insecureCompareLoop]
    | cons y ys => simp [insecureCompareLoop]
  | cons x xs ih =>
    cases supplied with
    | nil => simp [insecureCompareLoop]
    | cons y ys =>
      unfold insecureCompareLoop
      by_cases h : x = y
      · simp [h, ih]
      · simp [h]

def insecureCompare (expected supplied : List Nat) : Bool :=
  if expected.length = supplied.length then
    insecureCompareLoop expected supplied
  else
    false

theorem insecureCompare_correct (expected supplied : List Nat) :
  insecureCompare expected supplied = true ↔ expected = supplied := by
  unfold insecureCompare
  by_cases hlen : expected.length = supplied.length
  · simp [hlen, insecureCompareLoop_correct]
  · simp [hlen]
    intro heq
    subst heq
    exact hlen rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval insecureCompare [1, 2, 3] [1, 2, 3]
#eval insecureCompare [1, 2, 3] [9, 2, 3]
#eval insecureCompare [1, 2, 3] [1, 2, 9]
#eval insecureCompare [1, 2, 3] [1, 2]
#eval insecureCompare [] []
#eval insecureCompare [] [1]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.insecureCompare_correct

