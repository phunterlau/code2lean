import Std

namespace RepoVerifyAutogen

def isPowerOfTwo (n : Nat) : Bool :=
  if h0 : n = 0 then
    false
  else if h2 : n % 2 = 0 then
    isPowerOfTwo (n / 2)
  else if h1 : n = 1 then
    true
  else
    false
termination_by n
decreasing_by omega

theorem pow_two_pos (k : Nat) : 2^k > 0 := by
  induction k with
  | zero =>
    have h_one : 2^0 = 1 := rfl
    rw [h_one]
    omega
  | succ k ih =>
    have h_pow : 2^(k + 1) = 2^k * 2 := rfl
    rw [h_pow]
    omega

theorem isPowerOfTwo_correct_strong (n : Nat) :
  ∀ m < n, isPowerOfTwo m = true ↔ ∃ k, m = 2^k := by
  induction n with
  | zero =>
    intro m hm
    omega
  | succ step ih =>
    intro m hm
    have h_m : m < step ∨ m = step := by omega
    cases h_m with
    | inl h_lt => exact ih m h_lt
    | inr h_eq =>
      subst h_eq
      unfold isPowerOfTwo
      by_cases h0 : m = 0
      · rw [dif_pos h0]
        constructor
        · intro eq1; contradiction
        · rintro ⟨k, hk⟩
          have h_pos := pow_two_pos k
          omega
      · rw [dif_neg h0]
        by_cases h2 : m % 2 = 0
        · rw [dif_pos h2]
          have h_lt : m / 2 < m := by omega
          have ih2 := ih (m / 2) h_lt
          rw [ih2]
          constructor
          · rintro ⟨k, hk⟩
            exact ⟨k + 1, by
              have h_pow : 2^(k + 1) = 2^k * 2 := rfl
              rw [h_pow]
              have h_div : m = (m / 2) * 2 := by omega
              rw [h_div, hk]⟩
          · rintro ⟨k, hk⟩
            cases k with
            | zero =>
              have h_one : 2^0 = 1 := rfl
              rw [h_one] at hk
              omega
            | succ k =>
              exact ⟨k, by
                have h_pow : 2^(k + 1) = 2^k * 2 := rfl
                rw [h_pow] at hk
                omega⟩
        · rw [dif_neg h2]
          by_cases h1 : m = 1
          · rw [dif_pos h1]
            constructor
            · intro _
              exact ⟨0, h1⟩
            · intro _
              rfl
          · rw [dif_neg h1]
            constructor
            · intro h_false
              contradiction
            · rintro ⟨k, hk⟩
              cases k with
              | zero =>
                have h_one : 2^0 = 1 := rfl
                rw [h_one] at hk
                exact False.elim (h1 hk)
              | succ k =>
                have h_pow : 2^(k + 1) = 2^k * 2 := rfl
                rw [h_pow] at hk
                omega

theorem isPowerOfTwo_correct (n : Nat) : isPowerOfTwo n = true ↔ ∃ k, n = 2^k := by
  have h_lt : n < n + 1 := by omega
  exact isPowerOfTwo_correct_strong (n + 1) n h_lt

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

