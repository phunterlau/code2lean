# Roadmap

What's not measured yet, what's structurally missing, and the path
to vulnerability finding.

## Currently instrumented

The pipeline emits enough text per run to derive:

| Group | Metric | Status |
|-------|--------|--------|
| A | A6 — repair amplification (LLM calls per success) | yes — printed |
| B | B1 — diff-test pass/fail | yes — printed per case |
| D | D1 — axiom dependency set | yes — printed and gated |
| D | D2 — forbidden-token fast-fail | yes — sanitizer |
| E | E5 — rounds to convergence | yes — printed |

Per-call: input/output/reasoning/cached tokens, latency, model name,
Lean compile time across attempts, total wall-clock. `PRICING` in
`verify/llm.py` is left blank by default; filling in current
per-1M-token rates enables a dollar-cost line.

Everything else is uninstrumented. No automated rollup across runs
yet.

## Priority gaps

Ordered by where the next marginal hour of instrumentation pays off.

### 1. Distinguishability / mutation-kill (Group C1, B4)

This is **the** missing piece for vulnerability finding. The pitch:
pair every example with a deliberately buggy variant, re-run the
pipeline with the same theorem name, and require Lean to **fail** on
the buggy version. If it doesn't fail, the theorem is too weak —
exactly the failure mode the critic is supposed to catch but
sometimes doesn't.

What this would catch that nothing else does:

- WEAK theorems that the critic happened to accept (e.g., a
  bounds-only theorem on a function where the bound is the
  defining property)
- Mistranslations that pass the diff test by coincidence (the
  fixture didn't exercise the divergent branch)
- Mutation-equivalent implementations the proposed theorem doesn't
  distinguish

Implementation effort: **medium**. Each example needs a
`source_buggy.py` (or several). The pipeline already has all the
plumbing; you'd add a `--buggy-source` flag, run the same translate
prompt against the buggy file, and assert the Lean axiom check
*fails* (or specifically, that `sorryAx` appears, indicating the
proposer couldn't close the proof).

### 2. Property-based testing (Group B2)

The current diff test uses 5–7 hand-curated cases per example. A
buggy implementation that compares only the first three bytes of
`insecure_compare` would still pass the current
`01_insecure_compare` fixture.

Replacing or augmenting hand-curated cases with Hypothesis-style
random inputs (1000+ per example) would catch systematic
mistranslations that hand-picked cases miss.

Implementation effort: **medium**. The diff test runs both Python
and Lean per case, so the cost scales with case count × Lean
elaboration. `#eval` on a fresh argument is cheap; the bottleneck
is the per-Lean-process overhead, which would suggest either batch
`#eval` or a small persistent Lean server.

### 3. Pass@k (Group F1)

No "model A vs model B" claim is reliable at sample-size 1. The
current `benchmarks.md` numbers are from one trial per example.
Pass@k at k=3 or k=5 with temperature > 0 would tell us how much
of the model-comparison variance is signal vs. noise.

Implementation effort: **low** mechanically (rerun N times), **high**
in cost (N× the LLM bill). The right time to add this is right
before publishing model comparison claims.

### 4. Branch coverage (Groups B6, C2)

Two distinct uses of "branch coverage":

- **B6 (source coverage)**: of the Python function's branches, how
  many does the fixture exercise? Compute via `coverage.py` while
  running the diff test. Why: untested branches are where bugs hide.
  Effort: **low**.
- **C2 (theorem coverage)**: does the proven theorem logically
  exercise every branch? E.g., `clamp 0 0 0 = 0` doesn't; `lo ≤
  result ∧ result ≤ hi` does (across all three branches). Compute:
  symbolic analysis or LLM judgment. Effort: **medium-high**.

### 5. Kernel recheck (D6)

After `lake env lean` succeeds, run a follow-up `#check
@theorem_name` from a clean state, or load the `.olean` and verify it
type-checks again. Closes a small remaining gap in the soundness
gate (rules out elaboration-order side effects).

Implementation effort: **low**.

## Structural extensions

Larger pieces, not just metrics.

### Phase-2 critic loop

The critic is currently **one-shot**: it returns
`PASS / WEAK / FAIL`, and `WEAK`/`FAIL` are run failures. The critic
also produces a `STRONGER_THEOREM` (a Lean theorem statement ending
in `:= by sorry`) but the pipeline ignores it.

A Phase-2 loop would:

1. On `WEAK`, feed `STRONGER_THEOREM` back to the proposer with
   "prove this stronger statement instead."
2. Re-run gates A–D on the new attempt.
3. Re-critique.
4. Iterate up to a budget.

Done well, this would turn "verified" from "Lean accepted *some*
theorem" into "Lean accepted a theorem the critic also approves."
Done poorly, it's an expensive infinite loop. The decision rule
("did this round actually strengthen the theorem?") is the open
research question.

### Cost / side-channel models

The original HMAC demo (`source/`, `RepoVerify/TokenVerify.lean`)
proves both a **functional** and a **cost** theorem about byte
equality. The cost theorem is what distinguishes the vulnerable
implementation from the fixed one. The current pipeline doesn't
auto-derive cost models — only functional ones.

A natural extension: alongside `parityXor_correct`, ask the
proposer for `parityXor_cost_correct`, modeling some abstract notion
of observable cost (steps, branches, secret-dependent comparisons),
and gate on both. This is the architectural path from "general code
verifier" to "vulnerability finder," and is the long-term motivation
for the security framing in the README.

### Vulnerability-finding metrics (Group G)

When cost models exist, the relevant metrics become:

- **G1. Bug detection rate.** On a benchmark of known-buggy
  implementations (timing leaks, off-by-one, overflow), what fraction
  does the pipeline correctly flag? Effort: **high** (curating the
  benchmark).
- **G2. False-positive rate.** On known-correct implementations,
  how often is the pipeline wrong? Effort: **high**.
- **G3. False-negative rate.** Real bugs the pipeline misses.
  Effort: **high** (CVE-replay corpus).
- **G4. Counterexample interpretability.** When refutation succeeds,
  can a human read the Lean witness and reproduce a real-world
  attack? Effort: **medium**.
- **G5. Side-channel coverage.** Of canonical side channels (timing,
  cache, branch, memory, integer overflow, length, encoding, taint),
  how many does the pipeline's threat model currently cover? Effort:
  **low** (checklist).

### Multi-language adapters

See [scope-and-limits.md](scope-and-limits.md) for the per-language
adapter design. A second adapter (Rust or TypeScript) is the cleanest
way to validate the architecture's language-agnostic claims.

## What this roadmap explicitly defers

- **Custom Lean tactics.** The current prompt restricts the model to
  a small set of standard tactics. Tactic-shape coaching (specific
  `simp` lemma sets, `polyrith` for polynomial goals) would
  presumably help, but would also expand the trust surface.
- **Mathlib integration.** The pipeline imports only `Std`. Pulling
  in Mathlib gives the model a much larger lemma library but also a
  much larger axiom surface (Mathlib uses choice and noncomputable
  reasoning routinely). The allowlist gate would need to grow.
- **Proof minimization.** A Lean proof can be valid but bloated.
  Proof minimization is interesting for compactness/auditability but
  doesn't change the trust story.
- **Self-improvement loops.** Using past failures as training data
  for the next round is a different research project. The current
  pipeline treats every example as independent.
