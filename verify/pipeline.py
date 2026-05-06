"""Python function -> Lean translation -> Lean verification pipeline.

Workflow (fixture-driven):

  1. Resolve the target. Either:
       --example DIR        (load DIR/fixtures.py, which names source + cases)
       --source PATH --function NAME
                            (ad-hoc; no differential test unless a fixture exists)
  2. Extract the named Python function with `ast` (verify.extract).
  3. Ask an LLM (gpt-5.5, gemini-3.1-pro-preview, or claude-opus-4-7) to write a Lean 4 file that
     - models the function with natural Lean types,
     - states a functional-correctness theorem the model derives itself, and
     - proves it.
     The orchestrator fixes the *shape* (namespace, function name, theorem
     name) so it can validate the output, but does not prescribe the theorem
     statement.
  4. Append `#eval` lines for each fixture case and a `#print axioms` line.
     Compile with `lake env lean`. Repair on compile failure.
  5. On success, validate that:
     - the theorem depends only on `{propext, Classical.choice, Quot.sound}`,
     - the Lean `#eval`s agree with the Python function on every fixture case.

  Lean is the verifier; the LLM only proposes.

Examples are in `examples/<name>/{source.py,fixtures.py}`.

When `--example DIR` is used, the pipeline saves run artifacts back into
`DIR/` so the latest proposal is inspectable without re-running:

  DIR/last_lean_<provider>.lean       # the assembled Lean file (latest write)
  DIR/last_proposer_<provider>.txt    # raw proposer output for translate +
                                      #   each repair attempt, with headers
  DIR/last_critic_<critic>.txt        # raw critic output (only when --critic)

Filenames are namespaced by the model that produced them, so re-running
with a different `--provider` / `--critic` pair adds new files instead
of clobbering the previous run.
"""

from __future__ import annotations

import argparse
import importlib.util
import re
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Callable

from verify.critic import run_critic
from verify.extract import FunctionSpec, extract_function
from verify.llm import GenerationResult, Provider, estimate_cost_usd, get_provider

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES_DIR = ROOT / "examples"
LEAN_FILE = ROOT / "RepoVerify" / "Autogen.lean"

# Tokens we refuse to compile from LLM output. The list covers two threat
# classes: (a) raw soundness cheats (`sorry`, `axiom`, `partial`, ...), and
# (b) anything that lets the LLM body produce stdout that the orchestrator's
# log parser might mistake for its own diagnostics. The latter is critical
# because we read `#eval` and `#print axioms` output from the Lean log to
# decide whether the run passes; a model-controlled `dbg_trace` or extra
# `#eval` could spoof those values.
FORBIDDEN_TOKENS = (
    "sorry",
    "admit",
    "axiom ",
    "unsafe",
    "partial def",
    "noncomputable",
    "opaque",
    "set_option autoImplicit true",
    "dbg_trace",
    "IO.print",
    "IO.println",
    "BaseIO.print",
    "initialize ",
)

# Lean elaboration commands (`#eval`, `#print`, `#check`, `#reduce`, ...) all
# write to stdout. Only the orchestrator gets to use them; LLM bodies must
# stay silent so we can trust the log we parse.
HASH_COMMAND_RE = re.compile(r"(?m)^\s*#\w+")

# Sentinel `#eval`s wrap the orchestrator's diagnostic block. The log parser
# only reads `#eval` outputs sandwiched between BEGIN and END, and only
# accepts the axiom line that follows END. Combined with the forbidden-token
# filter above, this is defense-in-depth against a model that tries to spoof
# diagnostics from inside its own Lean body.
ORCH_BEGIN = "ORCH-DIAG-BEGIN-7c8e9d2a"
ORCH_END = "ORCH-DIAG-END-7c8e9d2a"

ALLOWED_AXIOMS = {"propext", "Classical.choice", "Quot.sound"}

DEFAULT_NAMESPACE = "RepoVerifyAutogen"


# --------------------------------------------------------------------------- #
# Naming
# --------------------------------------------------------------------------- #

def py_to_lean_name(snake: str) -> str:
    """`insecure_compare` -> `insecureCompare`."""
    parts = snake.split("_")
    return parts[0] + "".join(p.capitalize() for p in parts[1:])


# --------------------------------------------------------------------------- #
# Fixtures
# --------------------------------------------------------------------------- #

def default_to_lean_value(v: Any) -> str:
    """Convert a Python return value into the string Lean's `#eval` would print."""
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, int):
        return str(v)
    if isinstance(v, bytes):
        return "[" + ", ".join(str(b) for b in v) + "]"
    if isinstance(v, str):
        # Lean String uses double quotes with backslash escaping.
        return '"' + v.replace("\\", "\\\\").replace('"', '\\"') + '"'
    if isinstance(v, list):
        return "[" + ", ".join(default_to_lean_value(x) for x in v) + "]"
    if isinstance(v, tuple):
        return "(" + ", ".join(default_to_lean_value(x) for x in v) + ")"
    raise TypeError(
        f"default_to_lean_value: don't know how to render {type(v).__name__}; "
        f"override `to_lean_value` in your fixture."
    )


@dataclass
class Fixture:
    function: str                          # Python function name
    source: Path                           # absolute path to the .py file
    cases: list[tuple[tuple, str]] = field(default_factory=list)
    to_lean_value: Callable[[Any], str] = default_to_lean_value
    lean_fn: str | None = None             # optional override


def _is_inside_examples(path: Path) -> bool:
    try:
        path.resolve().relative_to(EXAMPLES_DIR.resolve())
        return True
    except ValueError:
        return False


def _check_exec_allowed(path: Path, *, allow_exec: bool, kind: str) -> None:
    """Refuse to `exec_module` arbitrary user code.

    Anything inside the repo's `examples/` directory is considered a
    curated fixture and is exec-allowed without further opt-in. Anything
    else (e.g. `--source /tmp/foo.py`) needs `--allow-exec` because the
    pipeline imports the module to read its functions, which runs any
    top-level code in that file.
    """
    if _is_inside_examples(path) or allow_exec:
        return
    raise PermissionError(
        f"Refusing to execute {kind} at {path}: it is outside {EXAMPLES_DIR}. "
        f"Re-run with --allow-exec if you trust this source."
    )


def load_fixture(fixture_path: Path, *, allow_exec: bool = False) -> Fixture:
    """Load `fixtures.py`. Recognized attributes:

    - FUNCTION (str, required): Python function name.
    - SOURCE   (str, optional): path to source file relative to fixtures.py;
                                defaults to "source.py" alongside it.
    - CASES    (list of (py_args_tuple, lean_call_str), optional): differential
                                test cases. Empty list = skip diff test.
    - LEAN_FN  (str, optional): override the camelCase Lean function name.
    - to_lean_value(v) -> str (callable, optional): converter for return values.
    """
    fixture_path = fixture_path.resolve()
    _check_exec_allowed(fixture_path, allow_exec=allow_exec, kind="fixture")
    spec = importlib.util.spec_from_file_location(
        f"_fixture_{fixture_path.parent.name}", fixture_path
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not import {fixture_path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    if not hasattr(module, "FUNCTION"):
        raise ValueError(f"{fixture_path}: missing FUNCTION = '<name>'")
    function = module.FUNCTION

    source_rel = getattr(module, "SOURCE", "source.py")
    source_path = (fixture_path.parent / source_rel).resolve()
    if not source_path.exists():
        raise FileNotFoundError(f"{fixture_path}: SOURCE not found at {source_path}")

    return Fixture(
        function=function,
        source=source_path,
        cases=list(getattr(module, "CASES", [])),
        to_lean_value=getattr(module, "to_lean_value", default_to_lean_value),
        lean_fn=getattr(module, "LEAN_FN", None),
    )


# --------------------------------------------------------------------------- #
# Prompts
# --------------------------------------------------------------------------- #

TYPE_MAPPING = """\
- `bool` -> `Bool`
- `int` (non-negative only) -> `Nat`; if negative values appear -> `Int`
- `bytes` -> `List Nat` (each byte is 0..255)
- `str` -> `String`
- `list[T]` -> `List <mapped-T>` (apply this rule recursively)
- `tuple[A, B]` -> `A × B`"""


def translate_prompt(spec: FunctionSpec, lean_fn: str, theorem: str, namespace: str) -> str:
    return f"""You are a Lean 4 proof engineer.

Goal: produce a Lean 4 file that models the following Python function and
proves a functional-correctness theorem about it. You decide the theorem
statement; aim for the strongest natural property that follows from the
function's signature and docstring.

Python function:
- file: {spec.file_path.name}
- signature: {spec.signature_summary()}
- source:
```
{spec.source}
```

Output requirements:
1. Single Lean 4 file. Output ONLY Lean code. No markdown fences, no commentary
   outside Lean comments.
2. The file MUST start with `import Std` (or no import) and define everything
   inside `namespace {namespace} ... end {namespace}`.
3. Inside the namespace, define a Lean function named `{lean_fn}` whose
   semantics mirror the Python function. Map Python types to Lean as follows:
{TYPE_MAPPING}
   Use total recursion only (Lean rejects partial functions).
4. Inside the namespace, state and prove a theorem named `{theorem}` that
   captures functional correctness of `{lean_fn}`. Examples of good targets,
   pick what fits this function:
   - equality predicate: `f xs ys = true <-> xs = ys`
   - boundary case: `f base = expected`
   - involution: `f (f x) = x`
   - bounded output: `f x <= bound x`
   - logical reflection: `f x = true <-> P x`
5. Constraints (auto-checked):
   - No `sorry`, `admit`, `axiom`, `unsafe`, `partial def`, `noncomputable`,
     `opaque`, or `set_option autoImplicit true`.
   - The theorem must depend only on standard axioms (`propext`,
     `Classical.choice`, `Quot.sound`).
6. Use only standard tactics (`induction`, `cases`, `simp`, `decide`, `rfl`,
   `omega`, `by_cases`, `subst`, `exact`, `refine`, `unfold`, `rw`,
   `Nat.succ.inj`, `Nat.add_comm`).

Return only the Lean file contents.
"""


def repair_prompt(
    spec: FunctionSpec,
    lean_fn: str,
    theorem: str,
    namespace: str,
    current: str,
    error_log: str,
) -> str:
    return f"""You are repairing a Lean 4 file you wrote earlier.

Constraints (unchanged):
- Lean 4 only, no markdown.
- Inside `namespace {namespace} ... end {namespace}`.
- Lean function named `{lean_fn}` modelling the Python function.
- Theorem named `{theorem}` proving functional correctness.
- No `sorry`, `admit`, `axiom`, `unsafe`, `partial def`, `noncomputable`,
  `opaque`, or `set_option autoImplicit true`.

Python function (for reference):
```
{spec.source}
```

Current Lean file:
```
{current}
```

Lean error output:
```
{error_log}
```

Return the FULL corrected Lean file. Output only Lean code.
"""


# --------------------------------------------------------------------------- #
# LLM output post-processing
# --------------------------------------------------------------------------- #

CODE_FENCE_RE = re.compile(r"```(?:lean)?\n(.*?)```", re.DOTALL)


def strip_code_fence(text: str) -> str:
    m = CODE_FENCE_RE.search(text)
    return (m.group(1) if m else text).strip()


def reject_unsafe(lean: str) -> None:
    """Fast-fail filter on LLM output.

    Two checks: the substring blocklist (soundness cheats + stdout
    producers) and a regex that forbids ANY `#`-prefixed elaboration
    command. Together they keep the LLM body from writing to the same
    stdout stream the orchestrator parses.
    """
    low = lean.lower()
    for tok in FORBIDDEN_TOKENS:
        if tok.lower() in low:
            raise ValueError(f"Generated Lean contains forbidden token: {tok!r}")
    m = HASH_COMMAND_RE.search(lean)
    if m:
        raise ValueError(
            f"Generated Lean contains a `#`-prefixed elaboration command "
            f"({m.group(0).strip()!r}). Only the orchestrator may emit "
            f"`#eval` / `#print` / `#check` lines."
        )


# --------------------------------------------------------------------------- #
# Lean file assembly
# --------------------------------------------------------------------------- #

def assemble_lean_file(
    llm_body: str,
    namespace: str,
    theorem: str,
    diff_cases: list[tuple[tuple, str]],
) -> str:
    """LLM body + orchestrator-controlled appendix (#evals + #print axioms).

    The diagnostic block is bracketed by sentinel `#eval` strings. The log
    parser only reads diff-test outputs between BEGIN and END, and only
    accepts the axiom line that follows END. Combined with the LLM-body
    sanitizer (`reject_unsafe`), this keeps a malicious model from spoofing
    the values we trust to make the pass/fail decision.
    """
    lines = ["", "-- Orchestrator-appended diagnostics. Do not edit by hand.", ""]
    lines.append(f"open {namespace}")
    lines.append(f'#eval "{ORCH_BEGIN}"')
    for _py_args, lean_call in diff_cases:
        lines.append(f"#eval {lean_call}")
    lines.append(f'#eval "{ORCH_END}"')
    lines.append(f"#print axioms {namespace}.{theorem}")
    lines.append("")
    return llm_body.rstrip() + "\n" + "\n".join(lines)


# --------------------------------------------------------------------------- #
# Lean run + log parsing
# --------------------------------------------------------------------------- #

def run_lean() -> tuple[bool, str, float]:
    """Returns (ok, stdout, wall_clock_seconds)."""
    t0 = time.perf_counter()
    proc = subprocess.run(
        ["lake", "env", "lean", str(LEAN_FILE.relative_to(ROOT))],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return proc.returncode == 0, proc.stdout, time.perf_counter() - t0


AXIOM_LINE_RE = re.compile(
    r"'[^']+'\s+(?:depends on axioms:\s*\[([^\]]*)\]|does not depend on any axioms)"
)


def _strip_lean_prefix(line: str) -> str | None:
    """Drop Lean's `info:` prefix; return None for warning/error/blank lines."""
    line = line.strip()
    if not line:
        return None
    if line.startswith("info:"):
        line = line[len("info:"):].strip()
        if not line:
            return None
    if line.startswith("warning:") or line.startswith("error:"):
        return None
    return line


def _split_log_by_sentinels(log: str) -> tuple[list[str], list[str]]:
    """Return (between_sentinels, after_end_sentinel).

    The orchestrator emits two sentinel `#eval` strings. We trust only:
      - the diff-test outputs between BEGIN and END
      - the axiom line printed after END

    Anything outside this band is ignored, so an LLM body that somehow
    bypasses `reject_unsafe` and emits its own `#eval` cannot poison the
    values the pipeline acts on.
    """
    between: list[str] = []
    after: list[str] = []
    state = "before"
    for raw in log.splitlines():
        cleaned = _strip_lean_prefix(raw)
        if cleaned is None:
            continue
        if state == "before":
            if ORCH_BEGIN in cleaned:
                state = "between"
            continue
        if state == "between":
            if ORCH_END in cleaned:
                state = "after"
                continue
            between.append(cleaned)
            continue
        # state == "after"
        after.append(cleaned)
    return between, after


def parse_axiom_line(log: str) -> tuple[bool, set[str], str]:
    """Parse the `#print axioms` line emitted AFTER the END sentinel.

    Anything matching the axiom-line shape that appears before END is
    ignored; only the orchestrator's own `#print axioms` is trusted.
    """
    _between, after = _split_log_by_sentinels(log)
    for line in after:
        m = AXIOM_LINE_RE.search(line)
        if not m:
            continue
        if m.group(1) is None:
            return True, set(), m.group(0)
        axioms = {a.strip() for a in m.group(1).split(",") if a.strip()}
        return True, axioms, m.group(0)
    return False, set(), ""


def extract_eval_results(log: str, n_expected: int) -> list[str]:
    """Return the diff-test `#eval` outputs that appeared between sentinels.

    Returns however many were emitted; the caller decides what counts as
    a mismatch. Length disagreement is treated as a hard failure upstream.
    """
    between, _after = _split_log_by_sentinels(log)
    return between[:n_expected] if n_expected > 0 else between


# --------------------------------------------------------------------------- #
# Differential test
# --------------------------------------------------------------------------- #

def import_python_function(spec: FunctionSpec, *, allow_exec: bool = False):
    _check_exec_allowed(spec.file_path, allow_exec=allow_exec, kind="source module")
    mod_spec = importlib.util.spec_from_file_location(
        f"_orch_{spec.name}", spec.file_path
    )
    if mod_spec is None or mod_spec.loader is None:
        raise RuntimeError(f"Could not import {spec.file_path}")
    module = importlib.util.module_from_spec(mod_spec)
    mod_spec.loader.exec_module(module)
    return getattr(module, spec.name)


def diff_test(
    spec: FunctionSpec,
    lean_eval_outputs: list[str],
    cases: list[tuple[tuple, str]],
    to_lean_value: Callable[[Any], str],
    *,
    allow_exec: bool = False,
) -> tuple[bool, list[str]]:
    fn = import_python_function(spec, allow_exec=allow_exec)
    notes: list[str] = []
    ok = True
    for (py_args, _lean_call), lean_out in zip(cases, lean_eval_outputs):
        py_value = fn(*py_args)
        py_str = to_lean_value(py_value)
        agree = py_str == lean_out
        marker = "ok" if agree else "MISMATCH"
        notes.append(
            f"  [{marker}] python({py_args!r}) -> {py_str}, lean -> {lean_out}"
        )
        if not agree:
            ok = False
    return ok, notes


# --------------------------------------------------------------------------- #
# Per-run artifact saving (latest Lean + raw LLM text per provider/critic)
# --------------------------------------------------------------------------- #

def _llm_call_header(label: str, gen: GenerationResult) -> str:
    return (
        f"=== {label}  model={gen.model}  "
        f"in={gen.input_tokens} out={gen.output_tokens} "
        f"reasoning={gen.reasoning_tokens} latency={gen.latency_s:.2f}s ==="
    )


def _save_proposer_artifact(
    artifact_dir: Path | None,
    provider_name: str,
    history: list[tuple[str, GenerationResult]],
) -> None:
    """Write the concatenated raw text of every proposer LLM call so far."""
    if artifact_dir is None or not history:
        return
    parts: list[str] = []
    for label, gen in history:
        parts.append(_llm_call_header(label, gen))
        parts.append(gen.text.rstrip())
        parts.append("")
    path = artifact_dir / f"last_proposer_{provider_name}.txt"
    path.write_text("\n".join(parts) + "\n")


def _save_critic_artifact(
    artifact_dir: Path | None,
    critic_name: str,
    gen: GenerationResult,
) -> None:
    if artifact_dir is None:
        return
    body = _llm_call_header("critic", gen) + "\n" + gen.text.rstrip() + "\n"
    (artifact_dir / f"last_critic_{critic_name}.txt").write_text(body)


def _save_lean_artifact(
    artifact_dir: Path | None,
    provider_name: str,
) -> None:
    """Copy the current LEAN_FILE contents into the example dir."""
    if artifact_dir is None or not LEAN_FILE.exists():
        return
    (artifact_dir / f"last_lean_{provider_name}.lean").write_text(
        LEAN_FILE.read_text()
    )


# --------------------------------------------------------------------------- #
# Run metrics
# --------------------------------------------------------------------------- #

@dataclass
class RunMetrics:
    """Per-run aggregator for cost / latency / repair metrics (A1–A4, A6)."""

    pipeline_start_s: float = field(default_factory=time.perf_counter)
    llm_calls: list[tuple[str, GenerationResult]] = field(default_factory=list)
    lean_compile_s: float = 0.0
    lean_attempts: int = 0

    def record_llm(self, label: str, result: GenerationResult) -> None:
        self.llm_calls.append((label, result))

    def record_compile(self, seconds: float) -> None:
        self.lean_compile_s += seconds
        self.lean_attempts += 1

    def total_input_tokens(self) -> int:
        return sum(r.input_tokens for _, r in self.llm_calls)

    def total_output_tokens(self) -> int:
        return sum(r.output_tokens for _, r in self.llm_calls)

    def total_reasoning_tokens(self) -> int:
        return sum(r.reasoning_tokens for _, r in self.llm_calls)

    def total_cached_input_tokens(self) -> int:
        return sum(r.cached_input_tokens for _, r in self.llm_calls)

    def total_llm_latency_s(self) -> float:
        return sum(r.latency_s for _, r in self.llm_calls)

    def repair_amplification(self) -> int:
        """A6: number of LLM calls per successful verification (1 = first try)."""
        return len(self.llm_calls)

    def render(self) -> list[str]:
        lines: list[str] = []
        lines.append("Run metrics:")
        lines.append(f"  LLM calls: {len(self.llm_calls)}  (A6 repair amplification)")
        for label, r in self.llm_calls:
            cost = estimate_cost_usd(r.model, r.input_tokens, r.output_tokens)
            cost_str = f", est ${cost:.4f}" if cost is not None else ""
            cache_str = (
                f", cached_in {r.cached_input_tokens}"
                if r.cached_input_tokens else ""
            )
            reason_str = (
                f", reasoning {r.reasoning_tokens}"
                if r.reasoning_tokens else ""
            )
            lines.append(
                f"    [{label}] in={r.input_tokens}{cache_str}, "
                f"out={r.output_tokens}{reason_str}, "
                f"{r.latency_s:.2f}s{cost_str}  ({r.model})"
            )
        in_total = self.total_input_tokens()
        out_total = self.total_output_tokens()
        cached_total = self.total_cached_input_tokens()
        reason_total = self.total_reasoning_tokens()
        llm_latency = self.total_llm_latency_s()
        lines.append(
            f"  LLM totals (A1+A2): input={in_total} (cached {cached_total}), "
            f"output={out_total} (reasoning {reason_total})"
        )
        lines.append(f"  LLM wall-clock (A4): {llm_latency:.2f}s across all calls")
        # Try a total cost estimate when pricing is configured per model.
        per_model_cost = []
        for _, r in self.llm_calls:
            c = estimate_cost_usd(r.model, r.input_tokens, r.output_tokens)
            if c is not None:
                per_model_cost.append(c)
        if per_model_cost:
            lines.append(
                f"  Estimated cost (A3): ${sum(per_model_cost):.4f}  "
                f"(set verify/llm.py PRICING for current rates)"
            )
        else:
            lines.append(
                "  Estimated cost (A3): n/a — fill verify/llm.py PRICING with "
                "current per-1M-token rates to enable."
            )
        lines.append(
            f"  Lean: {self.lean_compile_s:.2f}s across {self.lean_attempts} compile attempt(s)"
        )
        wall = time.perf_counter() - self.pipeline_start_s
        lines.append(f"  Pipeline wall-clock: {wall:.2f}s")
        return lines


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--example", type=Path,
                   help="Path to an example directory containing fixtures.py.")
    g.add_argument("--source", type=Path,
                   help="Path to a Python source file (use with --function).")
    p.add_argument("--function",
                   help="Python function name to verify (with --source).")
    p.add_argument("--provider", default="gemini",
                   choices=["openai", "gemini", "claude"],
                   help="Proposer LLM (default: gemini). Generates and "
                        "repairs the Lean translation + theorem.")
    p.add_argument("--critic", default=None,
                   choices=["openai", "gemini", "claude"],
                   help="Optional second LLM that judges the proposer's "
                        "theorem after Lean accepts it (Phase 1 of the "
                        "proposer/critic loop). Recommended: openai when "
                        "--provider=gemini.")
    p.add_argument("--max-repair", type=int, default=3,
                   help="Repair attempts after the initial generation (default: 3).")
    p.add_argument("--namespace", default=DEFAULT_NAMESPACE)
    p.add_argument("--allow-exec", action="store_true",
                   help="Allow exec_module on Python sources outside the "
                        "examples/ directory. Required for --source paths "
                        "that live elsewhere; not needed for --example.")
    return p.parse_args()


def resolve_target(
    args: argparse.Namespace,
) -> tuple[FunctionSpec, list[tuple[tuple, str]], Callable[[Any], str], str | None]:
    """Return (spec, diff_cases, to_lean_value, lean_fn_override)."""
    if args.example is not None:
        fixture_path = args.example / "fixtures.py"
        if not fixture_path.exists():
            sys.exit(f"No fixtures.py in {args.example}")
        try:
            fix = load_fixture(fixture_path, allow_exec=args.allow_exec)
        except PermissionError as e:
            sys.exit(str(e))
        spec = extract_function(fix.source, fix.function)
        return spec, fix.cases, fix.to_lean_value, fix.lean_fn

    if not args.function:
        sys.exit("--function is required when using --source")
    src_path = args.source.resolve()
    if not _is_inside_examples(src_path) and not args.allow_exec:
        sys.exit(
            f"Refusing to load {src_path}: it is outside {EXAMPLES_DIR}. "
            f"Re-run with --allow-exec if you trust this source."
        )
    spec = extract_function(src_path, args.function)
    return spec, [], default_to_lean_value, None


def _emit_metrics_and_exit(metrics: RunMetrics, code: int) -> int:
    for line in metrics.render():
        print(line)
    return code


def main() -> int:
    args = parse_args()
    metrics = RunMetrics()

    spec, diff_cases, to_lean_value, lean_fn_override = resolve_target(args)
    total_phases = 6 if args.critic else 5
    print(f"[1/{total_phases}] Extracted: {spec.signature_summary()}  (file: {spec.file_path.name})")

    provider: Provider = get_provider(args.provider)
    lean_fn = lean_fn_override or py_to_lean_name(spec.name)
    theorem = f"{lean_fn}_correct"
    namespace = args.namespace
    theorem_qualified = f"{namespace}.{theorem}"

    # Run artifacts (final Lean + raw LLM text) get saved here when the
    # target is an example directory. `--source` runs leave artifact_dir
    # as None and skip the saves.
    artifact_dir: Path | None = (
        args.example.resolve() if args.example is not None else None
    )
    proposer_history: list[tuple[str, GenerationResult]] = []

    if diff_cases:
        print(f"      Differential test: {len(diff_cases)} cases from fixture.")
    else:
        print("      Differential test: skipped (no cases).")

    print(f"[2/{total_phases}] Asking {provider.name} ({provider.model}) "
          f"for Lean translation + theorem `{theorem}`...")
    initial = provider.generate(translate_prompt(spec, lean_fn, theorem, namespace))
    metrics.record_llm("translate", initial)
    proposer_history.append(("translate", initial))
    _save_proposer_artifact(artifact_dir, provider.name, proposer_history)
    llm_body = strip_code_fence(initial.text)
    reject_unsafe(llm_body)
    LEAN_FILE.write_text(
        assemble_lean_file(llm_body, namespace, theorem, diff_cases) + "\n"
    )
    _save_lean_artifact(artifact_dir, provider.name)

    print(f"[3/{total_phases}] Compiling {LEAN_FILE.relative_to(ROOT)} "
          f"(max {args.max_repair} repair rounds)...")
    log = ""
    for attempt in range(args.max_repair + 1):
        ok, log, compile_s = run_lean()
        metrics.record_compile(compile_s)
        if ok:
            print(f"      Lean accepted on attempt {attempt} ({compile_s:.2f}s compile).")
            break
        if attempt == args.max_repair:
            print(f"      Lean still failed after {args.max_repair} repair attempts.")
            print("      Last error log (tail):\n")
            print(log[-2000:])
            return _emit_metrics_and_exit(metrics, 1)
        print(f"      Lean failed on attempt {attempt} ({compile_s:.2f}s); "
              f"asking {provider.name} to repair...")
        repair = provider.generate(
            repair_prompt(spec, lean_fn, theorem, namespace, llm_body, log)
        )
        metrics.record_llm(f"repair_{attempt}", repair)
        proposer_history.append((f"repair_{attempt}", repair))
        _save_proposer_artifact(artifact_dir, provider.name, proposer_history)
        llm_body = strip_code_fence(repair.text)
        reject_unsafe(llm_body)
        LEAN_FILE.write_text(
            assemble_lean_file(llm_body, namespace, theorem, diff_cases) + "\n"
        )
        _save_lean_artifact(artifact_dir, provider.name)

    # Axiom gate: HARD FAIL if missing or out of allowlist.
    found, axioms_used, raw_axiom_line = parse_axiom_line(log)
    if not found:
        print("      AXIOM CHECK FAILED: no `#print axioms` output found "
              "between the orchestrator's sentinel markers. Either Lean "
              "did not run the diagnostic block to completion, or the "
              "model body interfered with stdout.")
        print("      Last log (tail):\n" + log[-1500:])
        return _emit_metrics_and_exit(metrics, 1)
    bad = axioms_used - ALLOWED_AXIOMS
    if bad:
        print(f"      AXIOM CHECK FAILED: theorem uses non-allowlisted axioms: {bad}")
        print(f"      (raw: {raw_axiom_line})")
        return _emit_metrics_and_exit(metrics, 1)
    print(f"      Axiom check OK. Theorem uses: {axioms_used or '(none)'}")

    # Differential test: HARD FAIL on count mismatch or any disagreement.
    if diff_cases:
        eval_outputs = extract_eval_results(log, len(diff_cases))
        if len(eval_outputs) != len(diff_cases):
            print(f"      DIFFERENTIAL TEST FAILED: expected "
                  f"{len(diff_cases)} #eval outputs between sentinels, "
                  f"saw {len(eval_outputs)}.")
            print("      Last log (tail):\n" + log[-1500:])
            return _emit_metrics_and_exit(metrics, 1)
        diff_ok, notes = diff_test(
            spec, eval_outputs, diff_cases, to_lean_value,
            allow_exec=args.allow_exec,
        )
        for line in notes:
            print(line)
        if not diff_ok:
            print("      DIFFERENTIAL TEST FAILED: Python and Lean disagree.")
            return _emit_metrics_and_exit(metrics, 1)
        print("      Differential test OK.")

    print(f"[4/{total_phases}] Verified by Lean: `{theorem_qualified}`")
    print(f"      File: {LEAN_FILE.relative_to(ROOT)}")
    _save_lean_artifact(artifact_dir, provider.name)
    if artifact_dir is not None:
        rel = (artifact_dir / f"last_lean_{provider.name}.lean").relative_to(ROOT)
        print(f"      Saved artifact: {rel}")

    # Phase 1 critic round: a second model judges whether the theorem is a
    # meaningful characterization. Treats WEAK / FAIL / PARSE_ERROR as a
    # run failure even though Lean accepted the proof.
    if args.critic:
        if args.critic == args.provider:
            print(f"[5/{total_phases}] WARNING: --critic is the same "
                  f"provider as --provider ({args.critic}). Running "
                  f"anyway but you lose the cross-model signal.")
        critic_provider = get_provider(args.critic)
        print(f"[5/{total_phases}] Critic round: asking "
              f"{critic_provider.name} ({critic_provider.model}) to "
              f"review the theorem...")
        lean_text = LEAN_FILE.read_text()
        critic_report = run_critic(
            critic_provider, spec, lean_text, theorem_qualified, axioms_used
        )
        metrics.record_llm("critic", critic_report.generation)
        _save_critic_artifact(
            artifact_dir, critic_provider.name, critic_report.generation
        )
        print(f"      VERDICT: {critic_report.verdict}")
        print(f"      REASON:  {critic_report.reason}")
        if critic_report.stronger_theorem:
            print("      STRONGER_THEOREM (proposed, not proved):")
            for line in critic_report.stronger_theorem.splitlines():
                print(f"        {line}")
        if critic_report.verdict != "PASS":
            print(f"      CRITIC REJECTED THE THEOREM "
                  f"(verdict={critic_report.verdict}). Treating as a "
                  f"failed run.")
            return _emit_metrics_and_exit(metrics, 2)
        print("      Critic accepted.")

    print(f"[{total_phases}/{total_phases}]")
    return _emit_metrics_and_exit(metrics, 0)


if __name__ == "__main__":
    sys.exit(main())
