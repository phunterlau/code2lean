import Std

namespace RepoVerifyAutogen

def compareLoop : List Nat → List Nat → Bool
  | [], [] => true
  | e :: es, s :: ss => if e = s then compareLoop es ss else false
  | _, _ => false

def insecureCompareShortCircuit (expected supplied : List Nat) : Bool :=
  if expected.length = supplied.length then
    compareLoop expected supplied
  else
    false

theorem compareLoop_correct (xs ys : List Nat) :
    compareLoop xs ys = true ↔ xs = ys := by
  induction xs generalizing ys with
  | nil =>
      cases ys with
      | nil =>
          simp [compareLoop]
      | cons y ys =>
          simp [compareLoop]
  | cons x xs ih =>
      cases ys with
      | nil =>
          simp [compareLoop]
      | cons y ys =>
          by_cases h : x = y
          · subst y
            simp [compareLoop, ih]
          · simp [compareLoop, h]

theorem insecureCompareShortCircuit_correct (expected supplied : List Nat) :
    insecureCompareShortCircuit expected supplied = true ↔ expected = supplied := by
  unfold insecureCompareShortCircuit
  by_cases hlen : expected.length = supplied.length
  · rw [if_pos hlen]
    exact compareLoop_correct expected supplied
  · rw [if_neg hlen]
    exact Iff.intro
      (fun h => by
        cases h)
      (fun h => by
        subst supplied
        exact False.elim (hlen rfl))

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval insecureCompareShortCircuit [] []
#eval insecureCompareShortCircuit [1] [1]
#eval insecureCompareShortCircuit [1] [2]
#eval insecureCompareShortCircuit [1] [1, 2]
#eval insecureCompareShortCircuit [1, 2] [1]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.insecureCompareShortCircuit_correct

