import Std

namespace RepoVerify

/-
A small formal model of byte strings.

We use `List Nat` instead of Python `bytes`. This proves properties of the
modeled comparison algorithm, not of the Python interpreter itself.
-/

/-- Vulnerable early-exit equality. Functionally correct, but timing-leaky. -/
def insecureEq : List Nat → List Nat → Bool
  | [], [] => true
  | [], _ :: _ => false
  | _ :: _, [] => false
  | x :: xs, y :: ys =>
      if x = y then
        insecureEq xs ys
      else
        false

/-- The weak functional theorem is true. -/
theorem insecureEq_true_iff_eq (xs ys : List Nat) :
    insecureEq xs ys = true ↔ xs = ys := by
  induction xs generalizing ys with
  | nil =>
      cases ys <;> simp [insecureEq]
  | cons x xs ih =>
      cases ys with
      | nil =>
          simp [insecureEq]
      | cons y ys =>
          by_cases h : x = y
          · subst y
            simp [insecureEq, ih]
          · simp [insecureEq, h]

/--
Observable comparison cost for the vulnerable implementation.

Cost means number of byte comparisons before returning. This is a simplified
model of the timing side channel.
-/
def insecureEqCost : List Nat → List Nat → Nat
  | [], [] => 0
  | [], _ :: _ => 0
  | _ :: _, [] => 0
  | x :: xs, y :: ys =>
      if x = y then
        1 + insecureEqCost xs ys
      else
        1

#eval insecureEqCost [1, 2, 3] [9, 2, 3]
-- 1

#eval insecureEqCost [1, 2, 3] [1, 9, 3]
-- 2

#eval insecureEqCost [1, 2, 3] [1, 2, 9]
-- 3

/-- Concrete witness that the vulnerable comparison leaks prefix length. -/
example :
    insecureEqCost [1, 2, 3] [9, 2, 3] ≠
    insecureEqCost [1, 2, 3] [1, 2, 9] := by
  decide

/-- Constant-time-style equality model for equal-length byte strings. -/
def ctEq : List Nat → List Nat → Bool
  | [], [] => true
  | [], _ :: _ => false
  | _ :: _, [] => false
  | x :: xs, y :: ys =>
      let here := if x = y then true else false
      let rest := ctEq xs ys
      here && rest

/-- The fixed comparison is also functionally correct. -/
theorem ctEq_true_iff_eq (xs ys : List Nat) :
    ctEq xs ys = true ↔ xs = ys := by
  induction xs generalizing ys with
  | nil =>
      cases ys <;> simp [ctEq]
  | cons x xs ih =>
      cases ys with
      | nil =>
          simp [ctEq]
      | cons y ys =>
          by_cases h : x = y
          · subst y
            simp [ctEq, ih]
          · simp [ctEq, h]

/-- Cost model for the fixed comparison: walk all positions when lengths match. -/
def ctEqCost : List Nat → List Nat → Nat
  | [], [] => 0
  | [], _ :: _ => 0
  | _ :: _, [] => 0
  | _ :: xs, _ :: ys =>
      1 + ctEqCost xs ys

/-- Stronger security-relevant theorem: for same-length inputs, cost is content-independent. -/
theorem ctEqCost_eq_length_when_same_length
    (xs ys : List Nat)
    (h : xs.length = ys.length) :
    ctEqCost xs ys = xs.length := by
  induction xs generalizing ys with
  | nil =>
      cases ys with
      | nil =>
          simp [ctEqCost]
      | cons y ys =>
          simp at h
  | cons x xs ih =>
      cases ys with
      | nil =>
          simp at h
      | cons y ys =>
          have htail : xs.length = ys.length := by
            simpa using Nat.succ.inj h
          simp [ctEqCost, ih ys htail]

end RepoVerify
