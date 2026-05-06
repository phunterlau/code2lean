import Std

namespace RepoVerifyAutogen

def isPowerOfTwoAux : Nat → Nat → Bool
  | 0, _ => false
  | fuel + 1, n =>
      match n with
      | 0 => false
      | 1 => true
      | m + 2 =>
          if (m + 2) % 2 = 0 then
            isPowerOfTwoAux fuel ((m + 2) / 2)
          else
            false

def isPowerOfTwo (x : Nat) : Bool := isPowerOfTwoAux x x

lemma isPowerOfTwoAux_succ_succ (fuel m : Nat) :
    isPowerOfTwoAux (fuel + 1) (m + 2) =
      if (m + 2) % 2 = 0 then
        isPowerOfTwoAux fuel ((m + 2) / 2)
      else
        false := by
  rfl

lemma pow_two_succ_mod_two (k : Nat) : (2 ^ (k + 1)) % 2 = 0 := by
  rw [Nat.pow_succ]
  simp

lemma pow_two_succ_div_two (k : Nat) : (2 ^ (k + 1)) / 2 = 2 ^ k := by
  rw [Nat.pow_succ]
  simp

lemma no_zero_power_of_two : ¬ ∃ k : Nat, (0 : Nat) = 2 ^ k := by
  intro hp
  rcases hp with ⟨k, hk⟩
  have hpos : 0 < (2 : Nat) ^ k := Nat.pow_pos (by decide : 0 < (2 : Nat)) k
  rw [← hk] at hpos
  exact (lt_irrefl 0) hpos

lemma even_number_eq_two_mul_div (n : Nat) (hmod : n % 2 = 0) :
    n = 2 * (n / 2) := by
  have h := Nat.mod_add_div n 2
  rw [hmod] at h
  simpa using h.symm

lemma power_two_even_step (n : Nat) (hmod : n % 2 = 0) :
    ((∃ k : Nat, n / 2 = 2 ^ k) ↔ ∃ k : Nat, n = 2 ^ k) := by
  refine ⟨?_, ?_⟩
  · intro hp
    rcases hp with ⟨k, hk⟩
    refine ⟨k + 1, ?_⟩
    calc
      n = 2 * (n / 2) := even_number_eq_two_mul_div n hmod
      _ = 2 * 2 ^ k := by rw [hk]
      _ = 2 ^ (k + 1) := by
        rw [Nat.pow_succ]
        exact Nat.mul_comm 2 (2 ^ k)
  · intro hp
    rcases hp with ⟨k, hk⟩
    cases k with
    | zero =>
        have hn1 : n = 1 := by
          simpa using hk
        have hbad : False := by
          simpa [hn1] using hmod
        exact False.elim hbad
    | succ k =>
        refine ⟨k, ?_⟩
        rw [hk]
        exact pow_two_succ_div_two k

lemma no_power_of_two_of_odd_ge_two (n : Nat) (hmod : (n + 2) % 2 ≠ 0) :
    ¬ ∃ k : Nat, n + 2 = 2 ^ k := by
  intro hp
  rcases hp with ⟨k, hk⟩
  cases k with
  | zero =>
      have hsmall : n + 2 = 1 := by
        simpa using hk
      omega
  | succ k =>
      have heven : (n + 2) % 2 = 0 := by
        rw [hk]
        exact pow_two_succ_mod_two k
      exact hmod heven

lemma isPowerOfTwoAux_correct : ∀ fuel n : Nat, n ≤ fuel →
    isPowerOfTwoAux fuel n = true ↔ ∃ k : Nat, n = 2 ^ k := by
  intro fuel
  induction fuel with
  | zero =>
      intro n hn
      have hn0 : n = 0 := by omega
      subst n
      refine ⟨?_, ?_⟩
      · intro h
        have hf : False := by
          simpa [isPowerOfTwoAux] using h
        exact False.elim hf
      · intro hp
        exact False.elim (no_zero_power_of_two hp)
  | succ fuel ih =>
      intro n hn
      cases n with
      | zero =>
          refine ⟨?_, ?_⟩
          · intro h
            have hf : False := by
              simpa [isPowerOfTwoAux] using h
            exact False.elim hf
          · intro hp
            exact False.elim (no_zero_power_of_two hp)
      | succ n1 =>
          cases n1 with
          | zero =>
              refine ⟨?_, ?_⟩
              · intro _
                exact ⟨0, by simp⟩
              · intro _
                rfl
          | succ m =>
              by_cases hmod : (m + 2) % 2 = 0
              · have hlt : (m + 2) / 2 < m + 2 := by
                  exact Nat.div_lt_self (by omega) (by decide : 1 < 2)
                have hhalf : (m + 2) / 2 ≤ fuel := by
                  omega
                rw [isPowerOfTwoAux_succ_succ fuel m]
                simp [hmod]
                exact Iff.trans (ih ((m + 2) / 2) hhalf)
                  (power_two_even_step (m + 2) hmod)
              · have hno : ¬ ∃ k : Nat, m + 2 = 2 ^ k :=
                  no_power_of_two_of_odd_ge_two m hmod
                rw [isPowerOfTwoAux_succ_succ fuel m]
                simp [hmod]
                refine ⟨?_, ?_⟩
                · intro hfalse
                  exact False.elim hfalse
                · intro hp
                  exact False.elim (hno hp)

theorem isPowerOfTwo_correct (n : Nat) :
    isPowerOfTwo n = true ↔ ∃ k : Nat, n = 2 ^ k := by
  unfold isPowerOfTwo
  exact isPowerOfTwoAux_correct n n (Nat.le_refl n)

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

