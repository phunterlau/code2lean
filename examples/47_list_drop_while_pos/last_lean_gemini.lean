import Std

namespace RepoVerifyAutogen

def listDropWhilePos : List Nat → List Nat
| [] => []
| x :: xs => if x == 0 then x :: xs else listDropWhilePos xs

theorem listDropWhilePos_correct (xs : List Nat) :
  (0 ∉ xs ∧ listDropWhilePos xs = []) ∨
  (∃ as bs, xs = as ++ 0 :: bs ∧ 0 ∉ as ∧ listDropWhilePos xs = 0 :: bs) := by
  induction xs with
  | nil =>
    apply Or.inl
    refine ⟨?_, rfl⟩
    intro hc
    cases hc
  | cons x xs ih =>
    cases x with
    | zero =>
      apply Or.inr
      refine ⟨[], xs, rfl, ?_, rfl⟩
      intro hc
      cases hc
    | succ n =>
      cases ih with
      | inl h1 =>
        apply Or.inl
        refine ⟨?_, h1.2⟩
        intro hc
        have h_or := List.mem_cons.mp hc
        cases h_or with
        | inl h_eq => contradiction
        | inr h_mem => exact h1.1 h_mem
      | inr h2 =>
        cases h2 with
        | intro as h_as =>
          cases h_as with
          | intro bs h_bs =>
            apply Or.inr
            refine ⟨Nat.succ n :: as, bs, ?_, ?_, h_bs.2.2⟩
            · exact congrArg (fun l => Nat.succ n :: l) h_bs.1
            · intro hc
              have h_or := List.mem_cons.mp hc
              cases h_or with
              | inl h_eq => contradiction
              | inr h_mem => exact h_bs.2.1 h_mem

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listDropWhilePos []
#eval listDropWhilePos [0]
#eval listDropWhilePos [1, 2, 0, 3]
#eval listDropWhilePos [5, 4, 3]
#eval listDropWhilePos [0, 1, 2]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listDropWhilePos_correct

