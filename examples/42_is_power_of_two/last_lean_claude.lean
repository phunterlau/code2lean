namespace RepoVerifyAutogen

def isPowerOfTwo (n : Nat) : Bool :=
  if n = 0 then false
  else if n = 1 then true
  else if n % 2 = 0 then isPowerOfTwo (n / 2)
  else false
decreasing_by
  simp_wf
  omega

theorem isPowerOfTwo_correct (n : Nat) :
    isPowerOfTwo n = true ↔ ∃ k : Nat, n = 2 ^ k := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rw [isPowerOfTwo]
    by_cases h0 : n = 0
    · subst h0
      simp
      intro k hk
      cases k with
      | zero => simp at hk
      | succ m =>
        rw [Nat.pow_succ] at hk
        omega
    · simp [h0]
      by_cases h1 : n = 1
      · subst h1
        simp
        exact ⟨0, rfl⟩
      · simp [h1]
        by_cases h2 : n % 2 = 0
        · simp [h2]
          have hlt : n / 2 < n := by omega
          rw [ih (n / 2) hlt]
          constructor
          · rintro ⟨k, hk⟩
            refine ⟨k + 1, ?_⟩
            rw [Nat.pow_succ]
            have h2eq : n = 2 * (n / 2) := by
              have := Nat.div_add_mod n 2
              omega
            rw [h2eq, hk]
            ring
          · rintro ⟨k, hk⟩
            cases k with
            | zero => simp at hk; exact absurd hk h1
            | succ m =>
              refine ⟨m, ?_⟩
              rw [Nat.pow_succ] at hk
              have h2eq : n = 2 * (n / 2) := by
                have := Nat.div_add_mod n 2
                omega
              omega
        · simp [h2]
          intro k hk
          cases k with
          | zero => simp at hk; exact h1 hk
          | succ m =>
            rw [Nat.pow_succ] at hk
            omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval isPowerOfTwo 0
#eval isPowerOfTwo 1
#eval isPowerOfTwo 2
#eval isPowerOfTwo 3
#eval isPowerOfTwo 8
#eval isPowerOfTwo 12
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.isPowerOfTwo_correct

