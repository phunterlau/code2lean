namespace RepoVerifyAutogen

def index0Equals (xs : List Int) (x : Int) : Bool :=
  match xs with
  | [] => false
  | y :: _ => y == x

theorem index0Equals_correct (xs : List Int) (x : Int) :
  index0Equals xs x = true ↔ ∃ tail, xs = x :: tail := by
  cases xs with
  | nil => simp [index0Equals]
  | cons y ys => simp [index0Equals]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval index0Equals [] 0
#eval index0Equals [0] 0
#eval index0Equals [1] 0
#eval index0Equals [1, 2, 3] 1
#eval index0Equals [1, 2, 3] 2
#eval index0Equals [9, 9] 9
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.index0Equals_correct

