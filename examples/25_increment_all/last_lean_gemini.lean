namespace RepoVerifyAutogen

def incrementAll : List Int → List Int
  | [] => []
  | x :: xs => (x + 1) :: incrementAll xs

theorem incrementAll_correct (xs : List Int) : incrementAll xs = xs.map (fun x => x + 1) := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    unfold incrementAll
    rw [ih]
    rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval incrementAll []
#eval incrementAll [0]
#eval incrementAll [1, 2, 3]
#eval incrementAll [9, 0, 9]
#eval incrementAll [5, 5, 5]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.incrementAll_correct

