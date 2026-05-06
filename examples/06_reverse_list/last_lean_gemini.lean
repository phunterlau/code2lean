import Std

namespace RepoVerifyAutogen

def reverseListAux (xs : List Int) (out : List Int) : List Int :=
  match xs with
  | [] => out
  | x :: xs' => reverseListAux xs' (x :: out)

def reverseList (xs : List Int) : List Int :=
  reverseListAux xs []

theorem reverseListAux_eq_append (xs out : List Int) :
  reverseListAux xs out = reverseListAux xs [] ++ out := by
  induction xs generalizing out with
  | nil => rfl
  | cons x xs' ih =>
    calc
      reverseListAux (x :: xs') out = reverseListAux xs' (x :: out) := rfl
      _ = reverseListAux xs' [] ++ (x :: out) := ih (x :: out)
      _ = reverseListAux xs' [] ++ ([x] ++ out) := rfl
      _ = (reverseListAux xs' [] ++ [x]) ++ out := (List.append_assoc (reverseListAux xs' []) [x] out).symm
      _ = reverseListAux xs' [x] ++ out := by rw [← ih [x]]
      _ = reverseListAux (x :: xs') [] ++ out := rfl

theorem reverseListAux_append (xs ys out : List Int) :
  reverseListAux (xs ++ ys) out = reverseListAux ys (reverseListAux xs out) := by
  induction xs generalizing out with
  | nil => rfl
  | cons x xs' ih =>
    calc
      reverseListAux ((x :: xs') ++ ys) out = reverseListAux (x :: (xs' ++ ys)) out := rfl
      _ = reverseListAux (xs' ++ ys) (x :: out) := rfl
      _ = reverseListAux ys (reverseListAux xs' (x :: out)) := ih (x :: out)
      _ = reverseListAux ys (reverseListAux (x :: xs') out) := rfl

theorem reverseListAux_reverseListAux (xs out : List Int) :
  reverseListAux (reverseListAux xs []) out = xs ++ out := by
  induction xs generalizing out with
  | nil => rfl
  | cons x xs' ih =>
    calc
      reverseListAux (reverseListAux (x :: xs') []) out = reverseListAux (reverseListAux xs' [x]) out := rfl
      _ = reverseListAux (reverseListAux xs' [] ++ [x]) out := by rw [reverseListAux_eq_append xs' [x]]
      _ = reverseListAux [x] (reverseListAux (reverseListAux xs' []) out) := reverseListAux_append (reverseListAux xs' []) [x] out
      _ = reverseListAux [x] (xs' ++ out) := by rw [ih out]
      _ = reverseListAux [] (x :: (xs' ++ out)) := rfl
      _ = x :: (xs' ++ out) := rfl
      _ = (x :: xs') ++ out := rfl

theorem append_nil_eq (xs : List Int) : xs ++ [] = xs := by
  induction xs with
  | nil => rfl
  | cons x xs' ih =>
    calc
      (x :: xs') ++ [] = x :: (xs' ++ []) := rfl
      _ = x :: xs' := by rw [ih]

theorem reverseList_correct (xs : List Int) : reverseList (reverseList xs) = xs := by
  calc
    reverseList (reverseList xs) = reverseListAux (reverseListAux xs []) [] := rfl
    _ = xs ++ [] := reverseListAux_reverseListAux xs []
    _ = xs := append_nil_eq xs

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval reverseList []
#eval reverseList [7]
#eval reverseList [1, 2, 3]
#eval reverseList [5, 4, 3, 2, 1]
#eval reverseList [0, 0, 1]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.reverseList_correct

