import Std

namespace RepoVerifyAutogen

def byteMaxAux : List Nat → Nat → Nat
  | [], best => best
  | b :: bs, best => byteMaxAux bs (if best < b then b else best)

def byteMax (data : List Nat) : Nat :=
  byteMaxAux data 0

theorem byteMaxAux_ge_best (data : List Nat) (best : Nat) : best ≤ byteMaxAux data best := by
  induction data generalizing best with
  | nil => exact Nat.le_refl best
  | cons b bs ih =>
    unfold byteMaxAux
    have h := ih (if best < b then b else best)
    by_cases c : best < b
    · rw [if_pos c] at h ⊢
      omega
    · rw [if_neg c] at h ⊢
      omega

theorem byteMaxAux_ge_elem {data : List Nat} (x : Nat) (hx : x ∈ data) (best : Nat) : x ≤ byteMaxAux data best := by
  induction hx generalizing best with
  | head as =>
    unfold byteMaxAux
    have h := byteMaxAux_ge_best as (if best < x then x else best)
    by_cases c : best < x
    · rw [if_pos c] at h ⊢
      omega
    · rw [if_neg c] at h ⊢
      omega
  | tail b _ ih =>
    unfold byteMaxAux
    exact ih (if best < b then b else best)

theorem byteMax_correct (data : List Nat) (x : Nat) (hx : x ∈ data) : x ≤ byteMax data := by
  unfold byteMax
  exact byteMaxAux_ge_elem x hx 0

theorem byteMax_empty : byteMax [] = 0 := by
  rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval byteMax []
#eval byteMax [0]
#eval byteMax [1, 5, 3]
#eval byteMax [255, 0]
#eval byteMax [16, 32, 31]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.byteMax_correct

