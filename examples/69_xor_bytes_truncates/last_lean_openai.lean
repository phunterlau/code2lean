import Std

namespace RepoVerifyAutogen

def bitAt (x k : Nat) : Bool :=
  ((x / (2 ^ k)) % 2) == 1

def xorBit (p q : Bool) : Bool :=
  p != q

def xorBitValue (x y k : Nat) : Nat :=
  if xorBit (bitAt x k) (bitAt y k) then 2 ^ k else 0

def byteXor (x y : Nat) : Nat :=
  (List.range 8).foldl (fun acc k => acc + xorBitValue x y k) 0

def xorBytesTruncates (a b : List Nat) : List Nat :=
  if a.length ≠ b.length then [] else List.zipWith byteXor a b

theorem length_zipWith_eq_left {α β γ : Type} (f : α → β → γ) :
    ∀ (xs : List α) (ys : List β),
      xs.length = ys.length → (List.zipWith f xs ys).length = xs.length
  | [], [], _ => rfl
  | [], _ :: _, h => by cases h
  | _ :: _, [], h => by cases h
  | _ :: xs, _ :: ys, h => by
      simp [List.zipWith, length_zipWith_eq_left f xs ys (Nat.succ.inj h)]

theorem xorBytesTruncates_correct (a b : List Nat) :
    xorBytesTruncates a b =
        (if a.length = b.length then List.zipWith byteXor a b else []) ∧
      (a.length ≠ b.length → xorBytesTruncates a b = []) ∧
      (a.length = b.length → xorBytesTruncates a b = List.zipWith byteXor a b) ∧
      (xorBytesTruncates a b).length =
        if a.length = b.length then a.length else 0 := by
  unfold xorBytesTruncates
  by_cases h : a.length = b.length
  · simp [h, length_zipWith_eq_left byteXor a b h]
  · simp [h]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval xorBytesTruncates [] []
#eval xorBytesTruncates [1] [2]
#eval xorBytesTruncates [1, 2] [3, 4]
#eval xorBytesTruncates [1] [2, 3]
#eval xorBytesTruncates [255] [15]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.xorBytesTruncates_correct

