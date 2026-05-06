import Std

namespace RepoVerifyAutogen

def listFilterEven (xs : List Int) : List Int :=
  xs.filter (fun x => x % 2 == 0)

theorem listFilterEven_correct (xs : List Int) :
    ∀ x, x ∈ listFilterEven xs ↔ x ∈ xs ∧ x % 2 = 0 := by
  intro x
  unfold listFilterEven
  rw [List.mem_filter]
  simp

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

