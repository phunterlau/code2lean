import Std

namespace RepoVerifyAutogen

def listUniqueAux (seen : List Nat) : List Nat → List Nat
  | [] => seen
  | x :: xs =>
      if x ∈ seen then
        listUniqueAux seen xs
      else
        listUniqueAux (x :: seen) xs

def listUnique (xs : List Nat) : List Nat :=
  (listUniqueAux [] xs).reverse

theorem listUniqueAux_correct (seen xs : List Nat) :
    seen.Nodup →
      ((∀ x, x ∈ listUniqueAux seen xs ↔ x ∈ seen ∨ x ∈ xs) ∧
        (listUniqueAux seen xs).Nodup) := by
  induction xs generalizing seen with
  | nil =>
      refine fun hseen => ?_
      refine ⟨?_, ?_⟩
      · refine fun x => ?_
        simp [listUniqueAux]
      · simpa [listUniqueAux] using hseen
  | cons y ys ih =>
      refine fun hseen => ?_
      by_cases hy : y ∈ seen
      · have hrec := ih seen hseen
        refine ⟨?_, ?_⟩
        · refine fun z => ?_
          refine ⟨?_, ?_⟩
          · refine fun hmem => ?_
            have hz : z ∈ seen ∨ z ∈ ys :=
              (hrec.1 z).mp (by simpa [listUniqueAux, hy] using hmem)
            cases hz with
            | inl hzseen =>
                exact Or.inl hzseen
            | inr hzys =>
                exact Or.inr (by simp [hzys])
          · refine fun hmem => ?_
            have hz : z ∈ seen ∨ z ∈ ys := by
              cases hmem with
              | inl hzseen =>
                  exact Or.inl hzseen
              | inr hztail =>
                  have htail : z = y ∨ z ∈ ys := by
                    simpa using hztail
                  cases htail with
                  | inl hzy =>
                      subst z
                      exact Or.inl hy
                  | inr hzys =>
                      exact Or.inr hzys
            exact (by simpa [listUniqueAux, hy] using (hrec.1 z).mpr hz)
        · simpa [listUniqueAux, hy] using hrec.2
      · have hnew : (y :: seen).Nodup := by
          simp [hy, hseen]
        have hrec := ih (y :: seen) hnew
        refine ⟨?_, ?_⟩
        · refine fun z => ?_
          simpa [listUniqueAux, hy, or_assoc, or_left_comm, or_comm] using hrec.1 z
        · simpa [listUniqueAux, hy] using hrec.2

theorem nodup_append_singleton {α : Type} :
    ∀ (xs : List α) (x : α), xs.Nodup → x ∉ xs → (xs ++ [x]).Nodup
  | [], x, h, hx => by
      simp
  | y :: ys, x, h, hx => by
      have hparts : y ∉ ys ∧ ys.Nodup := by
        simpa using h
      have hxys : x ∉ ys := by
        intro hxy
        apply hx
        simp [hxy]
      have hyx : y ≠ x := by
        intro hyeq
        apply hx
        simp [hyeq]
      have ih := nodup_append_singleton ys x hparts.2 hxys
      have hynot : y ∉ ys ++ [x] := by
        intro hymem
        have hymem' : y ∈ ys ∨ y = x := by
          simpa using hymem
        cases hymem' with
        | inl hyys =>
            exact hparts.1 hyys
        | inr hyeq =>
            exact hyx hyeq
      simpa [hynot, ih]

theorem nodup_reverse {α : Type} : ∀ xs : List α, xs.Nodup → xs.reverse.Nodup
  | [], h => by
      simpa using h
  | x :: xs, h => by
      have hh : x ∉ xs ∧ xs.Nodup := by
        simpa using h
      have ih := nodup_reverse xs hh.2
      have hxrev : x ∉ xs.reverse := by
        simpa using hh.1
      simpa using nodup_append_singleton xs.reverse x ih hxrev

theorem listUnique_correct (xs : List Nat) :
    (∀ x, x ∈ listUnique xs ↔ x ∈ xs) ∧ (listUnique xs).Nodup := by
  have h := listUniqueAux_correct [] xs (by simp)
  refine ⟨?_, ?_⟩
  · refine fun x => ?_
    simpa [listUnique] using h.1 x
  · have hrev := nodup_reverse (listUniqueAux [] xs) h.2
    simpa [listUnique] using hrev

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listUnique []
#eval listUnique [1]
#eval listUnique [1, 1, 1]
#eval listUnique [1, 2, 1, 3, 2]
#eval listUnique [0, 1, 0, 2]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listUnique_correct

