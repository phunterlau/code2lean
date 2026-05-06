namespace RepoVerifyAutogen

def listUniqueAux : List Int → List Int → List Int
  | acc, [] => acc.reverse
  | acc, x :: xs =>
    if acc.contains x then listUniqueAux acc xs
    else listUniqueAux (x :: acc) xs

def listUnique (xs : List Int) : List Int := listUniqueAux [] xs

def pySpec : List Int → List Int → List Int
  | out, [] => out
  | out, x :: xs =>
    if out.contains x then pySpec out xs
    else pySpec (out ++ [x]) xs

theorem listUnique_correct (xs : List Int) :
    listUnique xs = pySpec [] xs := by
  unfold listUnique
  -- Prove by generalizing the accumulator
  suffices h : ∀ acc xs, listUniqueAux acc xs = pySpec acc.reverse xs by
    have := h [] xs
    simpa using this
  intro acc xs
  induction xs generalizing acc with
  | nil => simp [listUniqueAux, pySpec]
  | cons x xs ih =>
    unfold listUniqueAux pySpec
    have hr : acc.contains x = acc.reverse.contains x := by
      simp [List.contains_iff_exists_mem_beq, List.mem_reverse]
    rw [hr]
    by_cases h : acc.reverse.contains x = true
    · simp [h, ih]
    · simp [h]
      have hih := ih (x :: acc)
      simp at hih
      exact hih

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

