import Std

namespace RepoVerifyAutogen

def roundtripBytesNat (n : Nat) : Bool :=
  let hi := (n / 256) % 256
  let lo := n % 256
  let decoded := hi * 256 + lo
  decoded == (n % 65536)

theorem roundtripBytesNat_correct (n : Nat) : roundtripBytesNat n = true := by
  simp only [roundtripBytesNat, beq_iff_eq]
  omega

end RepoVerifyAutogen

-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval roundtripBytesNat 0
#eval roundtripBytesNat 1
#eval roundtripBytesNat 255
#eval roundtripBytesNat 256
#eval roundtripBytesNat 65535
#eval roundtripBytesNat 70000
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.roundtripBytesNat_correct

