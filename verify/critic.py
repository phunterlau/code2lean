"""Phase-1 critic for the proposer/critic loop (see ref/proposer-critic-plan.md).

The orchestrator runs the critic AFTER the proposer's Lean file has compiled,
passed the axiom allowlist, and matched Python output on every fixture case.
The critic re-reads the Python source and the proven theorem and judges
whether the theorem actually characterizes the function. Three possible
verdicts:

  PASS  - theorem is a meaningful functional-correctness statement.
  WEAK  - theorem compiles and is true, but is too weak (vacuous, only a
          boundary case, or a trivial equation that does not constrain
          behavior on inputs that matter). Treated as a run failure.
  FAIL  - theorem does not characterize the function at all (e.g. it
          ignores some arguments, contradicts the docstring, or is
          unrelated to the function's contract). Treated as a run failure.

The critic optionally proposes a STRONGER_THEOREM (Lean syntax, with
`sorry` as a placeholder) that a Phase-2 implementation would feed back
to the proposer. Phase 1 just records it.

This is intentionally a one-shot critic round - no iteration.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

from verify.extract import FunctionSpec
from verify.llm import GenerationResult, Provider


VALID_VERDICTS = {"PASS", "WEAK", "FAIL"}


@dataclass
class CriticReport:
    verdict: str                         # "PASS" | "WEAK" | "FAIL" | "PARSE_ERROR"
    reason: str
    stronger_theorem: str | None
    raw_text: str
    generation: GenerationResult


def critic_prompt(
    spec: FunctionSpec,
    lean_file: str,
    theorem_qualified: str,
    axioms_used: set[str],
) -> str:
    axiom_str = ", ".join(sorted(axioms_used)) if axioms_used else "(none)"
    return f"""You are a Lean 4 proof critic. Another model proposed a Lean
translation of a Python function and proved a functional-correctness theorem.
Your job is to judge whether that theorem actually pins down the function's
behavior, or whether it is too weak / unrelated.

Be skeptical. Common failure modes:
- The theorem only covers a boundary case (e.g. `f 0 = 1`) and says nothing
  about other inputs.
- The theorem is a tautology that holds for many functions, including buggy
  ones (e.g. `f x = f x`, or `f xs = true -> f xs = true`).
- The theorem matches the Python source structurally but misses a security
  property the docstring implies (e.g. constant-time behavior, content
  independence of timing, returns in a bounded range).
- The theorem is about a different function shape than the Python actually
  implements.

Python function (the ground truth):
- file: {spec.file_path.name}
- signature: {spec.signature_summary()}
- source:
```python
{spec.source}
```

Lean file the proposer produced (already compiled, axioms used: {axiom_str}):
```lean
{lean_file}
```

The theorem under review is `{theorem_qualified}`.

Reply in EXACTLY this format and nothing else - no markdown, no preamble:

VERDICT: <PASS | WEAK | FAIL>
REASON: <one or two sentences explaining the verdict>
STRONGER_THEOREM:
<Lean 4 theorem statement that would be a stronger characterization, ending
in `:= by sorry`. Use the same namespace and function name as the file
above. If verdict is PASS, write the single line "n/a" instead.>
"""


_VERDICT_RE = re.compile(r"^VERDICT:\s*(PASS|WEAK|FAIL)\s*$", re.MULTILINE)
_REASON_RE = re.compile(r"^REASON:\s*(.+?)(?=^STRONGER_THEOREM:|\Z)", re.MULTILINE | re.DOTALL)
_STRONGER_RE = re.compile(r"^STRONGER_THEOREM:\s*(.*)\Z", re.MULTILINE | re.DOTALL)


def parse_critic_response(text: str) -> tuple[str, str, str | None]:
    """Return (verdict, reason, stronger_theorem_or_None).

    `verdict` is "PARSE_ERROR" when the response did not match the requested
    format. We surface this rather than guess: a malformed critic response
    is itself a failure mode worth flagging.
    """
    v = _VERDICT_RE.search(text)
    if not v:
        return "PARSE_ERROR", "Critic response did not contain a recognizable VERDICT line.", None
    verdict = v.group(1).strip()

    r = _REASON_RE.search(text)
    reason = r.group(1).strip() if r else "(no reason provided)"

    s = _STRONGER_RE.search(text)
    stronger: str | None = None
    if s:
        body = s.group(1).strip()
        if body and body.lower() not in {"n/a", "na", "none"}:
            stronger = body

    return verdict, reason, stronger


def run_critic(
    critic_provider: Provider,
    spec: FunctionSpec,
    lean_file: str,
    theorem_qualified: str,
    axioms_used: set[str],
) -> CriticReport:
    prompt = critic_prompt(spec, lean_file, theorem_qualified, axioms_used)
    gen = critic_provider.generate(prompt)
    verdict, reason, stronger = parse_critic_response(gen.text)
    return CriticReport(
        verdict=verdict,
        reason=reason,
        stronger_theorem=stronger,
        raw_text=gen.text,
        generation=gen,
    )
