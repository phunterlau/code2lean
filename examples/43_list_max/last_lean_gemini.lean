import Std

namespace RepoVerifyAutogen

def listMaxAux : Int → List Int → Int
  | best, [] => best
  | best, y :: ys => listMaxAux (if best < y then y else best) ys

def listMax : List Int → Int
  | [] => 0
  | x :: xs => listMaxAux x (x :: xs)

def InList (y : Int) : List Int → Prop
  | [] => False
  | x :: xs => y = x ∨ InList y xs

theorem listMaxAux_ge_best (best : Int) (xs : List Int) : best ≤ listMaxAux best xs := by
  induction xs generalizing best with
  | nil =>
    unfold listMaxAux
    omega
  | cons x xs ih =>
    unfold listMaxAux
    by_cases h : best < x
    · have h1 : (if best < x then x else best) = x := by simp [h]
      rw [h1]
      have h2 := ih x
      omega
    · have h1 : (if best < x then x else best) = best := by simp [h]
      rw [h1]
      have h2 := ih best
      omega

theorem listMaxAux_ge_elem (xs : List Int) (best y : Int) (hy : InList y xs) : y ≤ listMaxAux best xs := by
  induction xs generalizing best y with
  | nil =>
    cases hy
  | cons x xs ih =>
    unfold listMaxAux
    by_cases h : best < x
    · have h2 : (if best < x then x else best) = x := by simp [h]
      rw [h2]
      cases hy with
      | inl h_eq =>
        rw [h_eq]
        exact listMaxAux_ge_best x xs
      | inr h_in =>
        exact ih x y h_in
    · have h2 : (if best < x then x else best) = best := by simp [h]
      rw [h2]
      cases hy with
      | inl h_eq =>
        rw [h_eq]
        have h3 := listMaxAux_ge_best best xs
        omega
      | inr h_in =>
        exact ih best y h_in

theorem listMaxAux_in (xs : List Int) (best : Int) : listMaxAux best xs = best ∨ InList (listMaxAux best xs) xs := by
  induction xs generalizing best with
  | nil =>
    unfold listMaxAux
    exact Or.inl rfl
  | cons x xs ih =>
    unfold listMaxAux
    by_cases h : best < x
    · have h2 : (if best < x then x else best) = x := by simp [h]
      rw [h2]
      have h1 := ih x
      cases h1 with
      | inl h_eq =>
        refine Or.inr ?_
        unfold InList
        exact Or.inl h_eq
      | inr h_in =>
        refine Or.inr ?_
        unfold InList
        exact Or.inr h_in
    · have h2 : (if best < x then x else best) = best := by simp [h]
      rw [h2]
      have h1 := ih best
      cases h1 with
      | inl h_eq =>
        exact Or.inl h_eq
      | inr h_in =>
        refine Or.inr ?_
        unfold InList
        exact Or.inr h_in

theorem listMax_correct :
  listMax [] = 0 ∧
  ∀ x xs, InList (listMax (x :: xs)) (x :: xs) ∧ ∀ y, InList y (x :: xs) → y ≤ listMax (x :: xs) := by
  refine And.intro ?_ ?_
  · unfold listMax
    rfl
  · refine fun x xs => And.intro ?_ ?_
    · have h := listMaxAux_in (x :: xs) x
      unfold listMax
      cases h with
      | inl h_eq =>
        unfold InList
        exact Or.inl h_eq
      | inr h_in =>
        exact h_in
    · refine fun y hy => ?_
      unfold listMax
      exact listMaxAux_ge_elem (x :: xs) x y hy

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval listMax []
#eval listMax [0]
#eval listMax [1, 2, 3]
#eval listMax [3, 2, 1]
#eval listMax [4, 9, 2, 9]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.listMax_correct

