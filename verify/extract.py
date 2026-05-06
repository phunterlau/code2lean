"""AST extraction of a single Python function for downstream Lean translation.

The orchestrator works against a structured `FunctionSpec` (signature, body,
docstring) rather than a raw file dump, so the prompt sent to the LLM is
focused on a single artifact and does not include unrelated module-level code
(imports, constants, tests).
"""

from __future__ import annotations

import ast
import textwrap
from dataclasses import dataclass
from pathlib import Path


@dataclass
class FunctionSpec:
    name: str
    source: str            # the def block, dedented to column 0
    docstring: str | None
    args: list[str]        # ["name: annotation"] or just ["name"]
    returns: str | None    # "bool", "int", etc., or None
    file_path: Path

    def signature_summary(self) -> str:
        arg_text = ", ".join(self.args) or "(no args)"
        ret_text = self.returns or "<unannotated>"
        return f"{self.name}({arg_text}) -> {ret_text}"


def _annotation_text(node: ast.AST | None) -> str | None:
    if node is None:
        return None
    return ast.unparse(node)


def _format_arg(arg: ast.arg) -> str:
    ann = _annotation_text(arg.annotation)
    return f"{arg.arg}: {ann}" if ann else arg.arg


def extract_function(file_path: Path, function_name: str) -> FunctionSpec:
    """Find `function_name` in `file_path` and return a FunctionSpec.

    Raises FileNotFoundError if the source is missing, and ValueError if the
    function does not exist or is nested inside a class (we don't support
    methods in this iteration).
    """
    file_path = Path(file_path)
    text = file_path.read_text()
    tree = ast.parse(text, filename=str(file_path))

    for node in tree.body:
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and node.name == function_name:
            source = textwrap.dedent(ast.get_source_segment(text, node) or "")
            return FunctionSpec(
                name=node.name,
                source=source,
                docstring=ast.get_docstring(node),
                args=[_format_arg(a) for a in node.args.args],
                returns=_annotation_text(node.returns),
                file_path=file_path,
            )

    raise ValueError(
        f"Function {function_name!r} not found at module scope in {file_path}. "
        "Methods inside classes are not supported in this iteration."
    )
