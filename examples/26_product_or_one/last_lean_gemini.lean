import Std

namespace RepoVerifyAutogen

def listProd : List Int → Int
  | [] => 1
  | x::xs => x * listProd xs

def productOrOneAux : List Int → Int → Int
  | [], acc => acc
  | x::xs, acc => productOrOneAux xs (acc * x)

def productOrOne (xs : List Int) : Int :=
  productOrOneAux xs 1

theorem productOrOneAux_eq (xs : List Int) (acc : Int) :
    productOrOneAux xs acc = acc * listProd xs := by
  induction xs generalizing acc with
  | nil =>
    unfold productOrOneAux
    unfold listProd
    rw [Int.mul_one]
  | cons x xs ih =>
    unfold productOrOneAux
    unfold listProd
    rw [ih (acc * x)]
    rw [Int.mul_assoc]

theorem productOrOne_correct (xs : List Int) :
    productOrOne xs = listProd xs := by
  unfold productOrOne
  rw [productOrOneAux_eq]
  rw [Int.one_mul]

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval productOrOne []
#eval productOrOne [0]
#eval productOrOne [1]
#eval productOrOne [2, 3, 4]
#eval productOrOne [5, 1, 2]
#eval productOrOne [7, 0, 9]
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.productOrOne_correct

