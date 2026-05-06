namespace RepoVerifyAutogen

def listDropWhilePos : List Int → List Int
  | [] => []
  | x :: xs => if x = 0 then x :: xs else listDropWhilePos xs

def pythonSpec (xs : List Int) : List Int :=
  let rec loop : List Int → List Int
    | [] => []
    | y :: ys => if y = 0 then y :: ys else loop ys
  loop xs

theorem listDropWhilePos_correct (xs : List Int) :
    listDropWhilePos xs = pythonSpec xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    simp [listDropWhilePos, pythonSpec, pythonSpec.loop]
    by_cases h : x = 0
    · simp [h]
    · simp [h]
      simp [pythonSpec, pythonSpec.loop] at ih
      exact ih

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

