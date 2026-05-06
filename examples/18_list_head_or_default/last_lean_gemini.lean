namespace RepoVerifyAutogen

def listHeadOrDefault (xs : List Int) : Int :=
  match xs with
  | [] => 0
  | x :: _ => x

theorem listHeadOrDefault_correct :
  listHeadOrDefault [] = 0 ∧ ∀ (x : Int) (xs : List Int), listHeadOrDefault (x :: xs) = x := by
  exact ⟨rfl, fun _ _ => rfl⟩

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listHeadOrDefault []
#eval listHeadOrDefault [0]
#eval listHeadOrDefault [7]
#eval listHeadOrDefault [1, 2, 3]
#eval listHeadOrDefault [9, 0, 9]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listHeadOrDefault_correct

