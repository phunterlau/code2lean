import Std

namespace RepoVerifyAutogen

def listFilterEven (xs : List Nat) : List Nat :=
  match xs with
  | [] => []
  | x :: xs' =>
    if x % 2 = 0 then
      x :: listFilterEven xs'
    else
      listFilterEven xs'

theorem listFilterEven_correct (xs : List Nat) (x : Nat) :
    x ∈ listFilterEven xs ↔ x ∈ xs ∧ x % 2 = 0 := by
  induction xs with
  | nil =>
    constructor
    · intro h
      cases h
    · intro h
      have ⟨h1, h2⟩ := h
      cases h1
  | cons y ys ih =>
    unfold listFilterEven
    split
    · rename_i hy
      constructor
      · intro h
        cases h
        · constructor
          · apply List.Mem.head
          · exact hy
        · rename_i hmem
          have ⟨h1, h2⟩ := ih.mp hmem
          constructor
          · apply List.Mem.tail
            exact h1
          · exact h2
      · intro h
        have ⟨h1, h2⟩ := h
        cases h1
        · apply List.Mem.head
        · rename_i hmem
          apply List.Mem.tail
          apply ih.mpr
          exact ⟨hmem, h2⟩
    · rename_i hnot
      constructor
      · intro h
        have ⟨h1, h2⟩ := ih.mp h
        constructor
        · apply List.Mem.tail
          exact h1
        · exact h2
      · intro h
        have ⟨h1, h2⟩ := h
        cases h1
        · exact False.elim (hnot h2)
        · rename_i hmem
          apply ih.mpr
          exact ⟨hmem, h2⟩

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listFilterEven []
#eval listFilterEven [1]
#eval listFilterEven [2]
#eval listFilterEven [1, 2, 3, 4]
#eval listFilterEven [0, 2, 4, 6]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listFilterEven_correct

