# Architecture and design thoughts

This is the "why," not the "how." The `pipeline.md` file walks through
what each phase does; this file argues why those phases exist.

## 1. The headline invariant

> **Lean is the verifier. The LLM is just a proposer.**

This sentence is load-bearing. Almost every design choice in
`verify/pipeline.py` exists to keep it true under a non-cooperative
LLM. If you stripped out the gates and trusted the model's claim that
"I generated a proof," you would learn nothing — a model can write
`theorem foo : P := sorry` and call that "verified."

Trust must come from **outside** the LLM. In this project, trust comes
from four things, in order of how cheap they are:

1. A substring + regex sanitizer that runs *before* Lean sees the file.
2. The Lean kernel itself, via `lake env lean`.
3. An axiom allowlist parsed from `#print axioms`.
4. A differential test against the original source's `#eval`-able
   semantics.

A fifth, expensive gate — an independent LLM critic — exists for a
*different* reason: to catch **vacuous theorems** that all four hard
gates pass. More on that below.

## 2. Why split proposer and verifier

The simplest workflow is "ask the LLM for a proof, run it." That
fails three ways:

- **Soundness cheats.** `sorry`, `admit`, `axiom foo : False` —
  trivial bypasses. Even sanitizing those, a model can pull
  `Classical.choice` into proofs that don't need it, or quietly emit
  `unsafe def` to skip totality.
- **Mistranslation.** The LLM might prove a true theorem about a Lean
  function that doesn't actually mirror the Python. Lean is happy; the
  source-vs-Lean drift is silent.
- **Vacuity.** The LLM proves something true but uninformative. `f 0
  = 1` for `factorial` is a true theorem and tells you nothing about
  the rest of the function. `result ≤ 8` for `bit_count8` is true even
  for a constant-zero implementation.

The first two are addressed by **hard gates** (mechanical, no LLM
involvement). The third is addressed by a **soft gate** (a second LLM
critic) because no mechanical check can identify "weak but not wrong."

## 3. The five gates

Each gate catches a different failure mode. Failing any one fails the
run.

| Gate | Implements | Catches |
|------|------------|---------|
| **A — Sanitizer** | `reject_unsafe` in `verify/pipeline.py` | `sorry`, `admit`, `axiom`, `partial def`, `unsafe`, `noncomputable`, `opaque`, `dbg_trace`, `IO.print*`, any `#`-prefixed elaboration command |
| **B — Lean compile** | `lake env lean` | Type errors, missing cases, malformed tactics. Repair loop kicks in here. |
| **C — Axiom allowlist** | `#print axioms` parsing + set check | Hidden `sorryAx`, smuggled `axiom` declarations, accidental `Classical.choice` when not needed |
| **D — Differential test** | `#eval` outputs vs Python `f(*args)` | Lean function disagrees with Python on a fixture case (mistranslation) |
| **E — Critic** | second LLM, `verify/critic.py` | Theorem too weak — bounds-only, boundary-only, function-against-itself, set-membership-instead-of-equality |

A–D are mechanical and cheap. E is the only LLM-judgment step in the
verification path. The repo's whole pitch is that you need both
mechanical gates **and** the critic — neither is sufficient alone.

## 4. Anti-spoofing — the sentinel design

The orchestrator parses Lean's stdout to decide pass/fail (axiom set,
`#eval` outputs). That's a trust boundary. A model body that emits its
own `#eval "true"` could poison the values the pipeline acts on.

Two defenses:

1. **Sanitizer regex** — any line beginning with `#` (`#eval`,
   `#print`, `#check`, ...) in the LLM body is rejected before
   compilation. Only the orchestrator gets to emit those.
2. **Sentinel-bracketed diagnostics** — the orchestrator wraps its own
   diagnostic block in:

   ```
   #eval "ORCH-DIAG-BEGIN-7c8e9d2a"
   <fixture #eval lines>
   #eval "ORCH-DIAG-END-7c8e9d2a"
   #print axioms <theorem>
   ```

   The log parser only reads diff-test outputs **between** BEGIN and
   END, and only accepts the axiom line that follows END. Anything
   outside this band is ignored.

Together, even if a model body somehow bypassed the sanitizer, it
couldn't poison the log.

## 5. The proposer picks the theorem itself

This is a deliberate, slightly counterintuitive choice.

The prompt fixes the **shape** (namespace, function name, theorem
name) so the orchestrator can mechanically validate the output. But
it does **not** prescribe the theorem statement. The proposer derives
that itself, with a single nudge:

> aim for the strongest natural property that follows from the
> function's signature and docstring

Why not hard-code the theorem? Two reasons:

1. **It generalizes.** A pipeline that only verifies a fixed list of
   theorem patterns is a tactic-picker, not a verifier. By letting
   the proposer pick the property, the pipeline scales to arbitrary
   functions without per-function prompt engineering.
2. **It exposes what each model "thinks correctness means."** When
   GPT-5.5 imports `Nat.lcm` and proves equality with the library
   function, that's a stronger spec than Gemini's "unfold the recursion
   against itself." That difference is invisible if you hand-pick the
   theorem.

The cost: vacuous theorems. A model that doesn't know what to prove
about `bit_count8` will prove `result ≤ 8`. Lean accepts. Diff-test
passes (because the bound is true). The critic exists precisely to
catch that.

## 6. Differential testing as a faithfulness check

The diff-test isn't trying to verify the function. The function is
verified by the proof. The diff-test verifies that the **Lean
function in the file actually models the Python function** — i.e.,
that the proof is about the right thing.

Concretely: we fix a small set of input/output cases in
`fixtures.py`, `#eval` the Lean function on each input, and require
the printed output to exactly match `python(*args)` rendered through
`default_to_lean_value`. Mismatch = mistranslation = run fails, even
if the proof was sound.

This is necessary because the LLM is responsible for both the Lean
function definition *and* the proof. A bug in the function definition
that the proof happens to be true about is otherwise undetectable.

## 7. Why the security demo motivates the whole thing

The `source/token_verify_*.py` + `RepoVerify/TokenVerify.lean` pair
isn't decoration; it's the architectural seed.

Two implementations of byte equality both satisfy the **functional**
theorem `compare xs ys = true ↔ xs = ys`. Only the constant-time one
satisfies the **cost** theorem `cost xs ys = xs.length` for same-length
inputs. The vulnerable one has a Lean-checkable counterexample showing
cost depends on contents.

The lesson: a verifier that only proves functional theorems would
green-light the vulnerable implementation. Real security needs
*stronger* theorems, and you have to ask whether the theorem you
proved is the right one.

The critic gate is the architectural answer to "how do you check the
theorem is the right one?" — at least under the assumption that an
independent LLM can recognize a vacuous theorem. That assumption
isn't airtight (see `roadmap.md` on mutation-kill), but it's
defensible and cheap.

## 8. AST-based extraction is what makes this language-agnostic

`verify/extract.py` uses Python's `ast` module to pull a single
function with its signature, docstring, and body. The extracted
`FunctionSpec` is what the LLM sees — not the raw file.

This matters for two reasons:

- **Prompt focus.** The model sees one function plus its types, not a
  500-line module. This keeps the prompt small and the model's
  attention narrow.
- **Language portability.** The same orchestrator works for any
  language with (a) an AST library, (b) a way to map types into Lean,
  and (c) an `eval`-equivalent for the differential test. The current
  code is Python-specific in `extract.py` and in
  `default_to_lean_value`, but those are the *only* language-specific
  pieces. Wiring up Rust, TypeScript, or Go would mostly mean writing
  a `<lang>_extract.py` that returns the same `FunctionSpec` shape and
  a value renderer for that language's primitives.

That's the asymmetry that makes the name `code2lean` honest rather
than aspirational: the architecture doesn't bake Python in — only
the current adapter does.

## 9. What this design deliberately does not do

- **No proof search.** The pipeline doesn't run Lean's `polyrith`,
  `omega`, etc. inside an outer loop. The LLM proposes whole proofs;
  Lean accepts or rejects. Repair is full-file rewrite, not tactic
  insertion.
- **No tactic feedback.** Lean's stdout (errors + axiom dump) is the
  only feedback channel. We don't surface goal state, LSP info, or
  intermediate proof states to the model.
- **No mutation generation in the pipeline.** Mutation testing of the
  Lean translation against the Python is in the roadmap (see
  `roadmap.md`); the current pipeline only does fixed-fixture diff
  testing.
- **No active learning.** Each run is independent. Failures don't
  feed back into the prompt for the next example.

These omissions are deliberate. Each one is a serious tooling
investment that would change the trust story (e.g., sharing tactic
state between the model and Lean opens new spoofing paths). The
current design is the minimum that gets the trust invariant right;
adding capability is a separate axis to the architecture.
