# Pipeline reference

How the orchestrator runs end-to-end. For the *why* behind each gate,
see [architecture.md](architecture.md).

## Phases

```
[1] Extract            verify/extract.py — AST-pull a single function from source.py
[2] Translate          LLM proposes Lean: function + theorem + proof
[3] Compile + repair   lake env lean Autogen.lean; on error, send full file + log back
                       to the proposer for up to --max-repair rounds
                         Gate A — sanitizer (forbidden tokens + no LLM-emitted #-commands)
                         Gate B — Lean compilation must succeed
[4] Soundness gate     parse `#print axioms <theorem>` after the END sentinel
                         Gate C — axiom set ⊆ {propext, Classical.choice, Quot.sound}
[5] Differential test  parse #eval outputs between BEGIN/END sentinels;
                       run the same args in Python; require exact agreement
                         Gate D — every fixture case must agree
[6] Critic (optional)  second LLM reads Python source + proven theorem
                       returns PASS / WEAK / FAIL
                         Gate E — must be PASS
```

A run command:

```bash
python -m verify.pipeline --example examples/01_insecure_compare \
  --provider gemini --critic openai --max-repair 3
```

## Phase 1 — Extract

`verify/extract.py` parses the named source file with `ast`,
finds the named function at module scope (methods inside classes are
rejected), and returns a `FunctionSpec`:

```python
@dataclass
class FunctionSpec:
    name: str
    source: str            # the def block, dedented
    docstring: str | None
    args: list[str]        # ["name: annotation"] or just ["name"]
    returns: str | None    # "bool", "int", etc.
    file_path: Path
```

Only the named function is extracted. Helpers, imports, and
module-level constants are not sent to the LLM. Anything the function
references at module scope must be inlined into the function or
stubbed in a fixture.

## Phase 2 — Translate

`translate_prompt` in `verify/pipeline.py` wraps the spec in a
prompt that:

1. Fixes the **shape**: namespace, function name (`py_to_lean_name`,
   e.g. `insecure_compare → insecureCompare`), theorem name
   (`<lean_fn>_correct`).
2. Pins a **type mapping**:
   - `bool → Bool`
   - `int (≥0) → Nat`; signed `int → Int`
   - `bytes → List Nat` (each byte 0..255)
   - `str → String`
   - `list[T] → List <mapped-T>`
   - `tuple[A, B] → A × B`
3. Asks for the **strongest natural property** the function admits,
   without prescribing what that property is.
4. Constrains tactics to a standard set (`induction`, `cases`, `simp`,
   `decide`, `rfl`, `omega`, `by_cases`, `subst`, `exact`, `refine`,
   `unfold`, `rw`, `Nat.succ.inj`, `Nat.add_comm`).

The provider abstraction (`verify/llm.py`) supports OpenAI
(`gpt-5.5`), Google (`gemini-3.1-pro-preview`), and Anthropic
(`claude-opus-4-7`) behind a single `provider.generate(prompt)`
interface that returns text plus billing-relevant metrics.

## Phase 3 — Compile + repair

The orchestrator strips a markdown code fence if present, runs Gate
A (sanitizer), assembles the Lean file (LLM body + appended
diagnostic block), writes it to `RepoVerify/Autogen.lean`, and shells
out to `lake env lean`.

### Gate A — sanitizer

`reject_unsafe` does two things:

- **Substring blocklist**: rejects `sorry`, `admit`, `axiom `,
  `unsafe`, `partial def`, `noncomputable`, `opaque`,
  `set_option autoImplicit true`, `dbg_trace`, `IO.print*`,
  `BaseIO.print`, `initialize `.
- **Regex `(?m)^\s*#\w+`**: rejects any `#`-prefixed elaboration
  command (`#eval`, `#print`, `#check`, `#reduce`, ...) in the LLM
  body. Only the orchestrator's diagnostic block may emit these.

The blocklist covers two threat classes: soundness cheats
(`sorry`/`axiom`/etc.) and stdout producers (`dbg_trace`,
`IO.print*`) that could spoof the log parser.

### Gate B — Lean compilation

The compile call:

```python
subprocess.run(
    ["lake", "env", "lean", "RepoVerify/Autogen.lean"],
    cwd=ROOT, ...,
)
```

If the return code is nonzero, the orchestrator captures the full
stdout/stderr and feeds it back to the proposer with `repair_prompt`,
asking for the *full corrected file* (not a diff). Up to
`--max-repair` rounds. If the budget runs out, the run fails with the
last error log printed.

The diagnostic block appended to every Lean file:

```lean
-- Orchestrator-appended diagnostics. Do not edit by hand.

open RepoVerifyAutogen
#eval "ORCH-DIAG-BEGIN-7c8e9d2a"
#eval <fixture call 1>
#eval <fixture call 2>
...
#eval "ORCH-DIAG-END-7c8e9d2a"
#print axioms RepoVerifyAutogen.<theorem>
```

The two sentinel `#eval`s bracket the diff-test outputs and isolate
them from anything Lean might print earlier (warnings, info messages
from elaboration). The `#print axioms` after END is the soundness
gate.

## Phase 4 — Axiom allowlist (Gate C)

`parse_axiom_line` reads only lines **after** the END sentinel,
matching:

```
'<theorem-name>' depends on axioms: [<comma-separated list>]
```

or:

```
'<theorem-name>' does not depend on any axioms
```

The parsed axiom set must be a subset of:

```
{propext, Classical.choice, Quot.sound}
```

Anything else — most importantly `sorryAx`, but also custom `axiom`
declarations or `Classical.byContradiction` if pulled in — fails the
run. The "anything before END" rule means a model that somehow
emitted its own `#print axioms` line couldn't poison the check.

## Phase 5 — Differential test (Gate D)

`extract_eval_results` reads the lines between BEGIN and END,
strips Lean's `info:` prefix, drops warnings/errors/blank lines, and
returns the cleaned `#eval` outputs.

`diff_test` then:

1. Imports the Python module (with sandbox check via
   `_check_exec_allowed` — see [scope-and-limits.md](scope-and-limits.md)).
2. For each `(py_args, lean_call)` pair in the fixture, runs the
   Python function with `py_args` and renders the result via
   `to_lean_value` (default or fixture-provided).
3. Compares to the corresponding Lean `#eval` output.

If the count of `#eval` outputs disagrees with the fixture case
count, that's a hard failure (something interfered with the diagnostic
block). Any mismatched value is also a hard failure.

## Phase 6 — Critic (Gate E, optional)

When `--critic <provider>` is set, after Lean accepts and the diff
test passes, the orchestrator hands the full Lean file + Python
source + axiom set to a second LLM with `critic_prompt`. The critic
returns:

```
VERDICT: <PASS | WEAK | FAIL>
REASON: <one or two sentences>
STRONGER_THEOREM:
<Lean theorem statement ending in `:= by sorry`, or the literal "n/a">
```

Verdicts:

- **PASS** — the theorem is a meaningful functional-correctness
  statement.
- **WEAK** — compiles and is true but too weak (vacuous, boundary
  case, trivial restatement). Treated as a run failure (exit 2).
- **FAIL** — the theorem doesn't characterize the function at all
  (ignores arguments, contradicts the docstring, unrelated). Run
  failure.
- **PARSE_ERROR** — the critic response didn't match the requested
  shape. Surfaced as failure rather than silently swallowed.

The critic is **one-shot**. There's no iteration where the critic's
`STRONGER_THEOREM` gets fed back to the proposer; that's a Phase-2
extension currently in the roadmap.

## Run artifacts

When `--example DIR` is used, each successful run writes:

```
DIR/last_lean_<provider>.lean       — the assembled Lean file
DIR/last_proposer_<provider>.txt    — raw proposer output for translate
                                      and each repair attempt, with headers
DIR/last_critic_<critic>.txt        — raw critic output (only when --critic)
```

Filenames are namespaced by model name, so re-running with a
different `--provider` or `--critic` adds files instead of clobbering
the previous run.

## Run metrics

`RunMetrics` aggregates per-run:

- LLM call count (= repair amplification, A6)
- Per-call input/output/reasoning/cached tokens
- Per-call latency
- Lean compile time across all attempts
- Total wall-clock

`PRICING` in `verify/llm.py` is left blank by default; filling in
per-1M-token rates for each model enables a dollar estimate in the
output.

## Exit codes

- `0` — all gates passed (or all four mechanical gates if `--critic`
  not given)
- `1` — sanitizer / Lean / axiom / diff-test failure
- `2` — critic returned WEAK / FAIL / PARSE_ERROR

This matters for CI: `0` means "verified," anything else means "do
not trust this run."
