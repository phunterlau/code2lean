"""GPT -> Lean security-verification loop.

This script asks an OpenAI model to generate a Lean file from the Python source
code, then runs Lean as the trusted checker. If Lean fails, it sends the error
back to the model for repair.

Important: GPT is not the verifier. Lean is the verifier.
"""

from __future__ import annotations

import os
import re
import subprocess
from pathlib import Path

from openai import OpenAI

ROOT = Path(__file__).resolve().parents[1]
VULN_SOURCE = ROOT / "source" / "token_verify_vulnerable.py"
FIXED_SOURCE = ROOT / "source" / "token_verify_fixed.py"
ATTACK_SOURCE = ROOT / "source" / "attack_demo.py"
LEAN_FILE = ROOT / "RepoVerify" / "AutogenFromGPT.lean"

MAX_REPAIR_ATTEMPTS = int(os.environ.get("MAX_REPAIR_ATTEMPTS", "5"))

FORBIDDEN = [
    "sorry",
    "admit",
    "axiom",
    "unsafe",
    "set_option autoImplicit true",
]


def get_model_name() -> str:
    model = os.environ.get("OPENAI_MODEL")
    if not model:
        raise RuntimeError(
            "Set OPENAI_MODEL to a Lean-capable model you can access, e.g. "
            "`export OPENAI_MODEL=gpt-5.5` if that API model is available."
        )
    return model


def strip_code_fence(text: str) -> str:
    match = re.search(r"```(?:lean)?\n(.*?)```", text, re.DOTALL)
    return match.group(1).strip() if match else text.strip()


def reject_bad_lean(lean_code: str) -> None:
    lowered = lean_code.lower()
    for token in FORBIDDEN:
        if token.lower() in lowered:
            raise ValueError(f"Generated Lean contains forbidden token: {token}")


def run_lean_file() -> tuple[bool, str]:
    proc = subprocess.run(
        ["lake", "env", "lean", str(LEAN_FILE.relative_to(ROOT))],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )
    return proc.returncode == 0, proc.stdout


def ask_gpt(prompt: str) -> str:
    client = OpenAI()
    response = client.responses.create(
        model=get_model_name(),
        input=prompt,
    )
    return strip_code_fence(response.output_text)


def initial_prompt(vulnerable_source: str, fixed_source: str, attack_source: str) -> str:
    return f"""
You are a Lean 4 proof engineer and security-verification assistant.

Task:
Generate a single Lean 4 file that models the relevant behavior of this Python
HMAC token-verification example. The key security lesson is that a weak theorem
can be true while the implementation is still timing-leaky.

Your Lean file must:
1. Import Std.
2. Create a namespace RepoVerifyAutogen.
3. Model vulnerable early-exit equality over List Nat.
4. Prove the weak functional theorem:
   vulnerable equality returns true iff the lists are equal.
5. Model observable comparison cost for the vulnerable equality.
6. Include a concrete counterexample showing equal-length inputs can have
   different costs.
7. Model a fixed constant-time-style equality and cost.
8. Prove the fixed equality is functionally correct.
9. Prove that for same-length inputs, the fixed cost equals the input length.
10. Use no sorry, admit, axiom, or unsafe.
11. Output only Lean code, no markdown.

Vulnerable Python source:
{vulnerable_source}

Fixed Python source:
{fixed_source}

Attack demo source:
{attack_source}
"""


def repair_prompt(
    vulnerable_source: str,
    fixed_source: str,
    attack_source: str,
    lean_code: str,
    build_log: str,
) -> str:
    return f"""
You are repairing a Lean 4 proof file.

Rules:
- Return the full corrected Lean file.
- Use no sorry, admit, axiom, or unsafe.
- Preserve the intended security lesson:
  weak functional theorem succeeds, vulnerable cost leaks, fixed cost is
  content-independent for same-length inputs.
- Output only Lean code.

Vulnerable Python source:
{vulnerable_source}

Fixed Python source:
{fixed_source}

Attack demo source:
{attack_source}

Current Lean file:
{lean_code}

Lean error output:
{build_log}
"""


def main() -> None:
    vulnerable_source = VULN_SOURCE.read_text()
    fixed_source = FIXED_SOURCE.read_text()
    attack_source = ATTACK_SOURCE.read_text()

    print("Generating initial Lean file from Python sources...")
    lean_code = ask_gpt(initial_prompt(vulnerable_source, fixed_source, attack_source))
    reject_bad_lean(lean_code)
    LEAN_FILE.write_text(lean_code + "\n")

    for attempt in range(MAX_REPAIR_ATTEMPTS + 1):
        ok, log = run_lean_file()
        if ok:
            print("✅ Lean accepted the generated proof file.")
            print(f"Verified generated file: {LEAN_FILE}")
            return

        print(f"❌ Lean failed on attempt {attempt}.")
        print(log[-4000:])

        if attempt == MAX_REPAIR_ATTEMPTS:
            raise RuntimeError("Lean proof did not verify after repair attempts.")

        print("Asking GPT to repair the Lean file...")
        lean_code = ask_gpt(
            repair_prompt(
                vulnerable_source=vulnerable_source,
                fixed_source=fixed_source,
                attack_source=attack_source,
                lean_code=lean_code,
                build_log=log,
            )
        )
        reject_bad_lean(lean_code)
        LEAN_FILE.write_text(lean_code + "\n")


if __name__ == "__main__":
    main()
