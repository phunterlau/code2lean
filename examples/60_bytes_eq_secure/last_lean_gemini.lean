import Std

namespace RepoVerifyAutogen

def bytesEqSecureLoop : List Nat → List Nat → Bool → Bool
  | [], _, same => same
  | _::_, [], same => same
  | x::xs, y::ys, same => bytesEqSecureLoop xs ys (same && (x == y))

theorem bytesEqSecureLoop_implies (a b : List Nat) (same : Bool) :
  bytesEqSecureLoop a b same = true →
  same = true ∧ (a.length = b.length → a = b) := by
  revert b same
  induction a with
  | nil =>
    intro b same h
    cases b with
    | nil => exact ⟨h, fun _ => rfl⟩
    | cons y ys => exact ⟨h, fun hlen => by cases hlen⟩
  | cons x xs ih =>
    intro b same h
    cases b with
    | nil => exact ⟨h, fun hlen => by cases hlen⟩
    | cons y ys =>
      have ih_res := ih ys (same && (x == y)) h
      have ⟨h_same, h_eq⟩ := ih_res
      have hs : same = true := by
        revert h_same
        cases same
        · intro contra; contradiction
        · intro _; rfl
      have hxy : x = y := by
        revert h_same
        cases same
        · intro contra; contradiction
        · intro h_same
          exact eq_of_beq h_same
      refine ⟨hs, fun hlen => ?_⟩
      have hl : xs.length = ys.length := Nat.succ.inj hlen
      have h_xs_ys : xs = ys := h_eq hl
      rw [hxy, h_xs_ys]

theorem bytesEqSecureLoop_true_of_eq (a : List Nat) (same : Bool) :
  bytesEqSecureLoop a a same = same := by
  induction a generalizing same with
  | nil => rfl
  | cons x xs ih =>
    have step : bytesEqSecureLoop (x :: xs) (x :: xs) same = bytesEqSecureLoop xs xs (same && (x == x)) := rfl
    rw [step]
    have hxx : (x == x) = true := beq_iff_eq.mpr rfl
    have h : (same && (x == x)) = same := by
      rw [hxx]
      cases same <;> rfl
    rw [h]
    exact ih same

def bytesEqSecure (a b : List Nat) : Bool :=
  bytesEqSecureLoop a b (a.length == b.length)

theorem bytesEqSecure_correct (a b : List Nat) :
  bytesEqSecure a b = true ↔ a = b := by
  constructor
  · intro h
    have h_loop := bytesEqSecureLoop_implies a b (a.length == b.length) h
    have ⟨h_len, h_eq⟩ := h_loop
    have h_len_eq : a.length = b.length := eq_of_beq h_len
    exact h_eq h_len_eq
  · intro h
    subst h
    have step : bytesEqSecure a a = bytesEqSecureLoop a a (a.length == a.length) := rfl
    rw [step]
    rw [bytesEqSecureLoop_true_of_eq a (a.length == a.length)]
    exact beq_iff_eq.mpr rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval bytesEqSecure [] []
#eval bytesEqSecure [1] [1]
#eval bytesEqSecure [1] [2]
#eval bytesEqSecure [1, 2, 3] [1, 2, 3]
#eval bytesEqSecure [1, 2, 3] [1, 2, 9]
#eval bytesEqSecure [1, 2] [1, 2, 3]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.bytesEqSecure_correct

