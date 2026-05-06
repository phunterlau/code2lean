# Scope and limits

What the pipeline can verify today, and what extending it would
look like.

## What gets accepted

`RepoVerify/Autogen.lean` is just a scratchpad — every run
overwrites it. The actual scope of what the pipeline can verify is
set by `verify/pipeline.py`, the proposer prompt, and
`verify/extract.py`.

The pipeline is **general for pure-functional source code** within
the slice below.

### Accepted

- **Single function defined at module scope.** Methods inside
  classes are rejected by `verify/extract.py`.
- **Pure** — no I/O, no global mutation, no side effects. The
  forbidden-token list bans `IO.print*`, `dbg_trace`, `initialize`,
  etc., and `reject_unsafe` rejects any `#`-prefixed elaboration
  command in the LLM body so it can't spoof the diagnostic block.
- **Total / terminating** — `partial def`, `noncomputable`, `opaque`,
  and `unsafe` are forbidden. Anything without a structurally
  decreasing Lean definition will not pass.
- **Types covered by the proposer's mapping table:**
  - `bool → Bool`
  - `int` (non-negative) `→ Nat`; signed `int → Int`
  - `bytes → List Nat`
  - `str → String`
  - `list[T] → List <mapped-T>` (recursive)
  - `tuple[A, B] → A × B`
- **Outputs the diff-test renderer (`default_to_lean_value`) can
  stringify**: bool, int, bytes, str, list, tuple. Anything else
  needs a custom `to_lean_value` in the fixture.

### Not handled

- Methods, classes, dataclasses, decorators, generators, `async`
- Floats, complex numbers, sets, dicts (no mapping in the prompt or
  renderer)
- numpy / pandas / external libraries, file or network or DB I/O,
  exceptions, mutable default arguments
- Functions that call other module-level helpers — only the named
  function is extracted and sent to the LLM; its collaborators are
  not included
- Probabilistic or non-deterministic functions — would break the
  differential test
- Concurrency, time, randomness

### Sandbox

`--source` paths outside `examples/` require `--allow-exec`, because
the pipeline imports the module to run the differential test and
that executes any top-level code in the file. The `examples/` tree
is treated as curated/trusted and is auto-allowed.

## The 80 examples

The `examples/` corpus lives entirely in this "pure, total,
simple-typed, single function" slice — crypto/byte primitives,
list/arithmetic utilities, Boolean predicates. Examples 60–80 cover
adversarial / edge cases (e.g., `66_insecure_compare_short_circuit`,
`67_factorial_off_by_one`, `73_saturating_add8_no_clamp`), still
within the same slice.

Stateful or framework-coupled code is out of scope and would need
either richer type/effect modeling in the prompt or a different
fixture protocol.

## Extending beyond Python

The architecture is language-agnostic; the *current adapter* is not.
Two pieces are Python-specific:

1. **`verify/extract.py`** — uses Python's `ast` to pull a
   `FunctionSpec` (name, source, docstring, args, return type).
2. **`verify/pipeline.py::default_to_lean_value`** — renders Python
   values as Lean expressions for the differential test.

Everything else (the prompts, the gates, the sentinel design, the
provider abstraction) is independent of the source language.

### What a new language adapter needs

To wire up Rust / TypeScript / Go / OCaml:

1. **AST extraction.** Implement a `<lang>_extract.py` that returns
   the same `FunctionSpec` shape:
   ```python
   FunctionSpec(
       name=...,
       source=...,         # the full function body, dedented
       docstring=...,      # if available
       args=[...],         # ["name: type"] strings
       returns=...,        # "type" or None
       file_path=...,
   )
   ```
   For Rust, `syn` via PyO3 or a `rustfmt`/`tree-sitter` pass would
   work; for TypeScript, `@typescript-eslint/parser`; for Go,
   `go/ast` driven by a small CLI; for OCaml, `compiler-libs`.

2. **Type mapping.** Update `TYPE_MAPPING` in
   `verify/pipeline.py::translate_prompt` (or hand it in as a
   per-language constant). Most simple types (`bool`, integers,
   lists, tuples, strings) map identically. Language-specific types
   (Rust's `Option<T>`, `Result<T, E>`; TypeScript's `null` / `undefined`)
   need explicit mapping rules.

3. **Value renderer.** Implement a `<lang>_to_lean_value` function
   that takes a value produced by the source language's runtime and
   renders it the same way Lean's `#eval` would print it. For
   `bool`, `int`, lists this is trivial; for language-specific types
   (`Option`, `Result`), it requires a small case split.

4. **Differential-test runtime.** The current `diff_test` imports
   the Python module and calls the function in-process. For other
   languages you'd shell out to a small runner (e.g. `cargo run` for
   Rust, `node` for TypeScript, `go run`) and parse stdout. The
   protocol is just "given JSON-encoded args, print the result";
   anything more is over-engineering.

5. **Sandbox.** Replicate `_check_exec_allowed` so paths outside
   `examples/` need `--allow-exec`. The threat model is "running
   untrusted source code"; it doesn't change between languages.

### What stays the same

- The five gates (sanitizer, compile, axiom allowlist, diff-test,
  critic) are language-independent. They operate on the Lean output,
  not the source language.
- The proposer/repair loop is language-independent. The prompt sees
  whatever string `FunctionSpec.source` contains, and the LLM produces
  Lean.
- The critic is language-independent. It judges the Lean theorem
  against the source-language function.
- The provider abstraction (`verify/llm.py`) doesn't care about the
  source language at all.

The asymmetry: porting to another language is roughly a few hundred
lines of adapter code, but the prompt's type-mapping rules will need
real thought for languages with richer type systems (lifetimes,
generics, traits, type classes).

## What the architecture deliberately does not commit to

- **Lean as the only target.** The provider abstraction would
  generalize to Coq, Isabelle, Agda, F* — anything with (a) a
  command-line type checker, (b) a way to print the trusted axiom
  set, and (c) an `eval`-equivalent. The sanitizer + sentinel
  pattern would need re-tuning per system, but the architecture
  doesn't bake Lean in.
- **A single proposer.** The pipeline supports multiple providers
  (`--provider gemini`, `--provider openai`, `--provider claude`),
  and the proposer/critic split is an intentional decoupling. An
  ensemble or fallback strategy is straightforward; see
  [benchmarks.md](benchmarks.md).
- **One-shot critic.** The current critic is one-shot (no
  iteration). A Phase-2 design would feed `STRONGER_THEOREM`
  suggestions back to the proposer. The interface is already there;
  what's missing is the loop and the "did this round actually
  improve the theorem" decision rule.
