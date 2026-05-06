# Example walkthrough: `34_parity_xor`

A single example traced end-to-end through every gate, using the
GPT-5.5 proposer + Claude critic pairing.

## 1. The Python function

`examples/34_parity_xor/source.py`:

```python
"""Arithmetic: parity XOR of two non-negative integers."""

def parity_xor(a: int, b: int) -> bool:
    """Return True iff exactly one of a and b is odd."""
    return (a % 2) != (b % 2)
```

## 2. The fixtures

`examples/34_parity_xor/fixtures.py`:

```python
FUNCTION = "parity_xor"

CASES = [
    ((0, 0),   "parityXor 0 0"),
    ((0, 1),   "parityXor 0 1"),
    ((1, 0),   "parityXor 1 0"),
    ((1, 1),   "parityXor 1 1"),
    ((8, 9),   "parityXor 8 9"),
    ((12, 20), "parityXor 12 20"),
]
```

Each entry is `(python_args, lean_eval_expression)`. The orchestrator
calls `parity_xor(*args)` in Python and `#eval`s the matching Lean
expression, then checks they agree.

## 3. The proposer prompt

The orchestrator asks GPT-5.5 to produce a Lean 4 file that:

1. Defines `parityXor` inside `namespace RepoVerifyAutogen` mirroring
   the Python.
2. States and proves a theorem named `parityXor_correct`
   characterizing the function for **all** inputs.

The prompt fixes the shape (namespace, function name, theorem name)
so the orchestrator can mechanically validate the output. It does
**not** prescribe the theorem statement — the proposer derives that
itself.

## 4. What GPT-5.5 produced

After 2 repair rounds (translate + repair_0 + repair_1), GPT-5.5
emitted:

```lean
import Std

namespace RepoVerifyAutogen

def parityXor (a b : Nat) : Bool :=
  decide ((a % 2) ≠ (b % 2))

def isOdd (n : Nat) : Prop :=
  n % 2 = 1

theorem mod_two_eq_zero_or_one (n : Nat) : n % 2 = 0 ∨ n % 2 = 1 := by
  have hlt : n % 2 < 2 := Nat.mod_lt n (by decide)
  omega

theorem parityXor_correct (a b : Nat) :
    parityXor a b = true ↔
      ((isOdd a ∧ ¬ isOdd b) ∨ (¬ isOdd a ∧ isOdd b)) := by
  unfold parityXor
  unfold isOdd
  have ha : a % 2 = 0 ∨ a % 2 = 1 := mod_two_eq_zero_or_one a
  have hb : b % 2 = 0 ∨ b % 2 = 1 := mod_two_eq_zero_or_one b
  cases ha with
  | inl ha0 =>
      cases hb with
      | inl hb0 => simp [ha0, hb0]
      | inr hb1 => simp [ha0, hb1]
  | inr ha1 =>
      cases hb with
      | inl hb0 => simp [ha1, hb0]
      | inr hb1 => simp [ha1, hb1]

end RepoVerifyAutogen
```

The theorem says: `parityXor a b = true` iff exactly one of `a`, `b`
is odd. The proof is a four-way case split on residues mod 2, with
`simp` discharging each branch.

## 5. Validation

### Gate A — Sanitizer

The output is checked against:

- substring blocklist (`sorry`, `axiom`, `partial`, `dbg_trace`, ...)
- regex `(?m)^\s*#\w+` (no LLM-emitted `#` commands)

Output passes.

### Gate B — Lean compile

The orchestrator appends a diagnostic block:

```lean
-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval parityXor 0 0
#eval parityXor 0 1
#eval parityXor 1 0
#eval parityXor 1 1
#eval parityXor 8 9
#eval parityXor 12 20
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.parityXor_correct
```

Then runs `lake env lean RepoVerify/Autogen.lean`. For this example,
3 attempts (5.23s total compile time): first try had a missing
import, second had a tactic shape Lean's elaborator rejected, third
closed cleanly.

The two sentinels (`ORCH-DIAG-BEGIN-…` / `ORCH-DIAG-END-…`) anchor
the log parser — anything between them is per-fixture output, in
fixture order.

### Gate C — Axiom allowlist

The trailer's `#print axioms` produced:

```
'RepoVerifyAutogen.parityXor_correct' depends on axioms: [propext]
```

Allowlist is `{propext, Classical.choice, Quot.sound}`. `propext`
alone is well within. Pass.

### Gate D — Differential test

The orchestrator parses the lines between BEGIN and END:

```
"ORCH-DIAG-BEGIN-7c8e9d2a"
false
true
true
false
true
false
"ORCH-DIAG-END-7c8e9d2a"
```

And zips them against `parity_xor(*args)` per fixture case:

```
[ok] python((0, 0))   -> false, lean -> false
[ok] python((0, 1))   -> true,  lean -> true
[ok] python((1, 0))   -> true,  lean -> true
[ok] python((1, 1))   -> false, lean -> false
[ok] python((8, 9))   -> true,  lean -> true
[ok] python((12, 20)) -> false, lean -> false
```

All six match.

### Gate E — Critic

Lean accepted the proof and the diff test passed, but the theorem
could still be too weak. So the orchestrator hands the theorem +
Python source to a second LLM:

```
VERDICT: PASS
REASON: The theorem characterizes parityXor as true iff exactly one
of a, b is odd, which is precisely the docstring's specification. It
covers all inputs and isn't a tautology.
```

If the verdict had been `WEAK` or `FAIL`, the run would have been
recorded as failed (exit code 2) with the suggested
`STRONGER_THEOREM` stored for review.

## 6. End state

All five gates passed. Final artifacts in
`examples/34_parity_xor/`:

```
last_lean_openai.lean       # the assembled Lean file
last_proposer_openai.txt    # raw GPT-5.5 output for translate +
                            #   each repair attempt, with model/
                            #   token/latency headers
last_critic_claude.txt      # raw critic verdict + REASON
```

## 7. Why this validation chain matters

Each gate catches a different failure mode the others miss:

| Gate | Catches |
|------|---------|
| A (sanitizer) | LLM emits a hash command, `axiom`, or unsafe import |
| B (Lean compile) | Type errors, unfinished proofs |
| C (axiom allowlist) | Hidden `sorryAx`, smuggled-in axioms |
| D (differential test) | Lean function disagrees with Python on a fixture case |
| E (LLM critic) | Theorem is too weak — bounds-only, boundary-only, function-against-itself, set-membership-instead-of-equality |

For `34_parity_xor` all five passed. For `41_bit_count8` (same
session) gates A–D all passed but the critic correctly returned
**WEAK**: the proposer's theorem was just `result ≤ 8`, which is true
even of a constant-zero implementation. **Lean cannot catch this; only
the critic (or mutation testing) can.**

That `41_bit_count8` outcome is the architectural pitch in
miniature: mechanical gates handle soundness; the critic handles
vacuity. Neither alone is sufficient.
