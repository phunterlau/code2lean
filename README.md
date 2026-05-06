# code2lean

> Source code → LLM proposer → Lean 4 verifier → multi-gate validation.
>
> *Lean is the verifier. The LLM is just a proposer.*

[English](README.md) · [简体中文](README.zh-Hans.md)

A pipeline that takes a function in source code, asks an LLM to
translate it into Lean 4 *and* propose a correctness theorem, then
runs five independent gates — sanitizer, Lean compile, axiom
allowlist, differential test against the original source, and a
second-LLM critic — to decide whether to trust the result.

The point is the gates, not the translation. An LLM can write
`theorem foo : P := sorry` and call it "verified." The whole design
exists to make that lie detectable.

## Why this exists

A theorem can be **formally correct** while the implementation it
describes still has a **security flaw**. The repo's seed example is
HMAC tag comparison:

- `source/token_verify_vulnerable.py` — early-exit byte loop;
  functionally correct, timing-leaky.
- `source/token_verify_fixed.py` — `hmac.compare_digest`;
  constant-time.
- `RepoVerify/TokenVerify.lean` — both the **functional** theorem
  (true for both implementations) and the **cost** theorem (only
  true for the fixed one).
- `source/attack_demo.py` — deterministic comparison-cost oracle
  that recovers the secret HMAC tag from the vulnerable
  implementation.

Run the attack:

```bash
python source/attack_demo.py
```

The recovered tag matches the secret. The lesson: a verifier that
only proves functional theorems would green-light the vulnerable
implementation. Real assurance needs *stronger* theorems, and you
have to ask whether the theorem you proved is the right one.

The generic pipeline (`verify/`) generalizes this question: for any
extracted function, does the proposed Lean theorem actually pin down
the function's behavior, or is it a vacuous restatement that any
buggy implementation would also satisfy?

## Quick start

### Install

Lean 4 / Lake (via [`elan`](https://github.com/leanprover/elan)),
plus Python ≥ 3.10:

```bash
git clone https://github.com/phunterlau/code2lean.git
cd code2lean
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
lake build
```

### Verify the handwritten Lean baseline

```bash
lake build
```

Type-checks `RepoVerify/TokenVerify.lean` (the original HMAC demo's
formal model: vulnerable + fixed equality, both functional theorems,
the leak counterexample, and the constant-time cost theorem).

### Run the pipeline on an example

Set one of the LLM API keys, then run:

```bash
export OPENAI_API_KEY=...        # for --provider openai
export GEMINI_API_KEY=...        # for --provider gemini
export ANTHROPIC_API_KEY=...     # for --provider claude

python -m verify.pipeline \
  --example examples/01_insecure_compare \
  --provider gemini \
  --critic openai \
  --max-repair 3
```

The pipeline:

1. AST-extracts the named function from `source.py`.
2. Asks the proposer to write a Lean 4 file (function + theorem +
   proof).
3. Compiles with `lake env lean`. Repairs on failure.
4. Validates with `#print axioms` (allowlist: `propext`,
   `Classical.choice`, `Quot.sound`).
5. Differential-tests Lean `#eval` outputs against the Python
   function on every fixture case.
6. Optionally has a second LLM critic verdict the theorem
   (`PASS / WEAK / FAIL`).

Exit code:

- `0` — all gates passed
- `1` — sanitizer / Lean / axiom / diff-test failure
- `2` — critic returned `WEAK` / `FAIL` / `PARSE_ERROR`

### Run the original attack demo

```bash
python -m pytest                              # functional + recovery test
python source/attack_demo.py                  # deterministic timing-leak attack
```

## How it works (one diagram)

```
[source.py] ─► AST extract ─► proposer (LLM) ─► Lean file
                                                     │
                                                     ▼
                                           Gate A: sanitizer
                                           Gate B: lake env lean ──repair loop──► proposer
                                           Gate C: axiom allowlist
                                           Gate D: differential test (Python ↔ Lean)
                                           Gate E: critic (second LLM)
                                                     │
                                                     ▼
                                              PASS / fail
```

`A`–`D` are mechanical gates, no LLM judgment in the verification
path. `E` is the only LLM-judgment step, and it exists to catch
**vacuous theorems** (`result ≤ 8` for `bit_count8` is true even of
a constant-zero implementation; Lean accepts it; the critic catches
it). See [docs/architecture.md](docs/architecture.md) for the why
and [docs/pipeline.md](docs/pipeline.md) for the how.

## What gets verified — scope

`code2lean` works on any source language with an AST library and a
type system that maps to Lean. The current adapter is Python; the
architecture is language-agnostic.

**Within Python today, the pipeline accepts:**

- Single function at module scope (no methods)
- Pure / total / terminating
- Types: `bool`, `int` (signed or unsigned), `bytes`, `str`,
  `list[T]`, `tuple[A, B]`

**It does not handle** classes, decorators, generators, `async`,
floats, dicts, sets, numpy / external libraries, file or network
I/O, exceptions, randomness, or functions that depend on
module-level helpers.

Full details and what extending to Rust / TypeScript / Go would look
like: [docs/scope-and-limits.md](docs/scope-and-limits.md).

## Examples

`examples/` has 80 small Python functions (byte/list manipulation,
arithmetic, Boolean predicates, crypto-flavored primitives) each
paired with a fixture for the differential test. Past run artifacts
(`last_lean_<provider>.lean`, `last_proposer_<provider>.txt`,
`last_critic_<critic>.txt`, `pipeline_*.log`) are checked in as
samples. See [examples/README.md](examples/README.md) for the full
list and `--example` invocation.

## Files

```
verify/
  pipeline.py                 # orchestrator — gates A–D + repair loop
  extract.py                  # AST extraction → FunctionSpec
  llm.py                      # OpenAI / Gemini / Claude provider abstraction
  critic.py                   # gate E — Phase-1 critic (PASS/WEAK/FAIL)
  gpt_to_lean_security.py     # legacy single-file GPT→Lean demo (the seed)
RepoVerify/
  TokenVerify.lean            # handwritten Lean baseline (the security demo)
  Autogen.lean                # pipeline target — overwritten on each run
  AutogenFromGPT.lean         # legacy target for gpt_to_lean_security.py
source/                       # original HMAC demo Python
tests/                        # pytest for the original demo
examples/                     # 80 functions × fixtures + run artifacts
docs/                         # design notes, walkthrough, benchmarks, roadmap
```

## Docs

| File | Read it for |
|------|-------------|
| [docs/architecture.md](docs/architecture.md) | Design thoughts: trust model, proposer/verifier, the five gates, anti-spoofing |
| [docs/pipeline.md](docs/pipeline.md) | End-to-end pipeline reference |
| [docs/example-walkthrough.md](docs/example-walkthrough.md) | Single example (`34_parity_xor`) traced through every gate |
| [docs/benchmarks.md](docs/benchmarks.md) | Three-way Gemini/Claude/GPT proposer comparison + caveats |
| [docs/scope-and-limits.md](docs/scope-and-limits.md) | What can be verified today; extending to other languages |
| [docs/roadmap.md](docs/roadmap.md) | Mutation-kill, pass@k, distinguishability, vulnerability finding |

## License

MIT. See `LICENSE`.
