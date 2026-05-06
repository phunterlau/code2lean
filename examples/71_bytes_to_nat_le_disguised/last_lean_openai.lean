import Std

namespace RepoVerifyAutogen

def pow256 : Nat -> Nat
  | 0 => 1
  | Nat.succ n => 256 * pow256 n

def bytesToNatLeDisguisedAux : List Nat -> Nat -> Nat
  | [], n => n
  | b :: rest, n => bytesToNatLeDisguisedAux rest (n * 256 + b)

def bytesToNatLeDisguised (data : List Nat) : Nat :=
  bytesToNatLeDisguisedAux data 0

def bytesToNatBESpec : List Nat -> Nat
  | [] => 0
  | b :: rest => b * pow256 rest.length + bytesToNatBESpec rest

theorem bytesToNatLeDisguised_aux_arith (acc b p s : Nat) :
    (acc * 256 + b) * p + s = acc * (256 * p) + (b * p + s) := by
  rw [Nat.add_mul]
  rw [Nat.mul_assoc]
  rw [Nat.add_assoc]

theorem bytesToNatLeDisguisedAux_correct (data : List Nat) (acc : Nat) :
    bytesToNatLeDisguisedAux data acc =
      acc * pow256 data.length + bytesToNatBESpec data := by
  induction data generalizing acc with
  | nil =>
      simp [bytesToNatLeDisguisedAux, bytesToNatBESpec, pow256]
  | cons b rest ih =>
      calc
        bytesToNatLeDisguisedAux (b :: rest) acc
            = bytesToNatLeDisguisedAux rest (acc * 256 + b) := by
                rfl
        _ = (acc * 256 + b) * pow256 rest.length + bytesToNatBESpec rest := by
                rw [ih]
        _ = acc * (256 * pow256 rest.length) +
              (b * pow256 rest.length + bytesToNatBESpec rest) := by
                rw [bytesToNatLeDisguised_aux_arith]
        _ = acc * pow256 (b :: rest).length + bytesToNatBESpec (b :: rest) := by
                simp [pow256, bytesToNatBESpec]

theorem bytesToNatLeDisguised_correct (data : List Nat) :
    bytesToNatLeDisguised data = bytesToNatBESpec data := by
  unfold bytesToNatLeDisguised
  rw [bytesToNatLeDisguisedAux_correct]
  simp

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval bytesToNatLeDisguised []
#eval bytesToNatLeDisguised [0]
#eval bytesToNatLeDisguised [1]
#eval bytesToNatLeDisguised [1, 0]
#eval bytesToNatLeDisguised [1, 2, 3]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.bytesToNatLeDisguised_correct

