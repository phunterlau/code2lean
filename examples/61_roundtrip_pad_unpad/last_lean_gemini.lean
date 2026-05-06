import Std

namespace RepoVerifyAutogen

theorem len_append (xs ys : List Nat) : (xs ++ ys).length = xs.length + ys.length := by
  induction xs with
  | nil =>
    change ys.length = 0 + ys.length
    rw [Nat.zero_add]
  | cons x xs ih =>
    change (xs ++ ys).length + 1 = xs.length + 1 + ys.length
    rw [ih]
    omega

theorem len_replicate (n a : Nat) : (List.replicate n a).length = n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    change (List.replicate n a).length + 1 = n + 1
    rw [ih]

def getIdx (xs : List Nat) (i : Nat) : Option Nat :=
  match xs, i with
  | [], _ => none
  | a::_, 0 => some a
  | _::as, n+1 => getIdx as n

theorem getIdx_append_right (xs ys : List Nat) : ∀ i, xs.length ≤ i → getIdx (xs ++ ys) i = getIdx ys (i - xs.length) := by
  induction xs with
  | nil =>
    intro i h
    change getIdx ys i = getIdx ys (i - 0)
    have eq : i - 0 = i := by omega
    rw [eq]
  | cons x xs ih =>
    intro i h
    cases i with
    | zero =>
      change xs.length + 1 ≤ 0 at h
      omega
    | succ i =>
      change xs.length + 1 ≤ i + 1 at h
      change getIdx (xs ++ ys) i = getIdx ys (i + 1 - (xs.length + 1))
      have eq : i + 1 - (xs.length + 1) = i - xs.length := by omega
      rw [eq]
      have h1 : xs.length ≤ i := by omega
      exact ih i h1

theorem getIdx_replicate (n a : Nat) : ∀ i, i < n → getIdx (List.replicate n a) i = some a := by
  induction n with
  | zero =>
    intro i h
    omega
  | succ n ih =>
    intro i h
    cases i with
    | zero =>
      rfl
    | succ i =>
      change i + 1 < n + 1 at h
      change getIdx (List.replicate n a) i = some a
      have h1 : i < n := by omega
      exact ih i h1

theorem take_append_left (xs ys : List Nat) : (xs ++ ys).take xs.length = xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    change x :: ((xs ++ ys).take xs.length) = x :: xs
    rw [ih]

def roundtripPadUnpad (data : List Nat) : Bool :=
  let pad_len := 16 - (data.length % 16)
  let padded := data ++ List.replicate pad_len pad_len
  let last := (getIdx padded (padded.length - 1)).getD 0
  let unpadded := padded.take (padded.length - last)
  unpadded == data

theorem roundtripPadUnpad_correct (data : List Nat) : roundtripPadUnpad data = true := by
  have len_padded : (data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).length = data.length + (16 - (data.length % 16)) := by
    have h1 := len_append data (List.replicate (16 - (data.length % 16)) (16 - (data.length % 16)))
    have h2 := len_replicate (16 - (data.length % 16)) (16 - (data.length % 16))
    rw [h2] at h1
    exact h1

  have get_last_eq : (getIdx (data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))) ((data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).length - 1)).getD 0 = 16 - (data.length % 16) := by
    have h_idx : (data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).length - 1 = data.length + (16 - (data.length % 16)) - 1 := by rw [len_padded]
    rw [h_idx]
    have h_ge : data.length ≤ data.length + (16 - (data.length % 16)) - 1 := by omega
    have h_get := getIdx_append_right data (List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))) (data.length + (16 - (data.length % 16)) - 1) h_ge
    rw [h_get]
    have h_idx2 : data.length + (16 - (data.length % 16)) - 1 - data.length = (16 - (data.length % 16)) - 1 := by omega
    rw [h_idx2]
    have h_lt : (16 - (data.length % 16)) - 1 < (16 - (data.length % 16)) := by omega
    have h_get_rep := getIdx_replicate (16 - (data.length % 16)) (16 - (data.length % 16)) ((16 - (data.length % 16)) - 1) h_lt
    rw [h_get_rep]
    rfl

  have take_len : (data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).length - (getIdx (data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))) ((data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).length - 1)).getD 0 = data.length := by
    rw [get_last_eq]
    rw [len_padded]
    omega

  have h_take : (data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).take ((data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).length - (getIdx (data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))) ((data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).length - 1)).getD 0) = data := by
    rw [take_len]
    exact take_append_left data (List.replicate (16 - (data.length % 16)) (16 - (data.length % 16)))

  unfold roundtripPadUnpad
  change ((data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).take ((data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).length - (getIdx (data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))) ((data ++ List.replicate (16 - (data.length % 16)) (16 - (data.length % 16))).length - 1)).getD 0) == data) = true
  rw [h_take]
  simp

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval roundtripPadUnpad []
#eval roundtripPadUnpad [1]
#eval roundtripPadUnpad [1, 2, 3]
#eval roundtripPadUnpad [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.roundtripPadUnpad_correct

