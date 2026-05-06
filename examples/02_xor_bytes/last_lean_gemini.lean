import Std

namespace RepoVerifyAutogen

def xorBytes : List Nat → List Nat → List Nat
  | [], _ => []
  | _::_, [] => []
  | x::xs, y::ys => (x ^^^ y) :: xorBytes xs ys

theorem xorBytes_correct (a b : List Nat) :
    xorBytes a b = List.zipWith (fun x y => x ^^^ y) a b := by
  induction a generalizing b with
  | nil =>
    cases b with
    | nil => rfl
    | cons y ys => rfl
  | cons x xs ih =>
    cases b with
    | nil => rfl
    | cons y ys =>
      simp only [xorBytes]
      rw [ih ys]
      rfl

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval xorBytes [1, 2] [3, 4]
#eval xorBytes [0, 0] [255, 255]
#eval xorBytes [170, 170] [170, 170]
#eval xorBytes [] []
#eval xorBytes [255] [15]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.xorBytes_correct

