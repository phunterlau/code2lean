"""Provider abstraction for LLM calls.

Three providers are supported:

- OpenAI (`gpt-5.5`) via the Responses API.
  https://developers.openai.com/api/docs/guides/latest-model
- Gemini (`gemini-3.1-pro-preview`) via the google-genai SDK.
  https://ai.google.dev/gemini-api/docs/gemini-3
- Anthropic Claude (`claude-opus-4-7`) via the Messages API.
  https://platform.claude.com/docs/en/api/sdks/python

All expose a single `.generate(prompt) -> GenerationResult` method so the
orchestrator stays provider-agnostic. `GenerationResult` carries the text plus
billing-relevant metrics (input tokens, output tokens, reasoning/cache splits,
latency).
"""

from __future__ import annotations

import os
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass


@dataclass
class GenerationResult:
    text: str
    input_tokens: int           # billed input (prompt)
    cached_input_tokens: int    # subset of input that hit prompt cache (often free/cheap)
    output_tokens: int          # billed output, INCLUDES reasoning_tokens when present
    reasoning_tokens: int       # subset of output that's hidden chain-of-thought
    latency_s: float
    model: str


# Pricing in USD per 1M tokens. Fill in current values from each provider's
# pricing page; leave both keys at None to skip the dollar estimate. The
# orchestrator prints raw token counts unconditionally and only adds a
# dollar-cost line when both values are set.
PRICING: dict[str, dict[str, float | None]] = {
    "gpt-5.5":                {"input_per_m": None, "output_per_m": None},
    "gemini-3.1-pro-preview": {"input_per_m": None, "output_per_m": None},
    "claude-opus-4-7":        {"input_per_m": None, "output_per_m": None},
}


def estimate_cost_usd(model: str, input_tokens: int, output_tokens: int) -> float | None:
    p = PRICING.get(model)
    if not p or p["input_per_m"] is None or p["output_per_m"] is None:
        return None
    return (
        input_tokens * p["input_per_m"] + output_tokens * p["output_per_m"]
    ) / 1_000_000


class Provider(ABC):
    name: str
    model: str

    @abstractmethod
    def generate(self, prompt: str) -> GenerationResult: ...


class OpenAIProvider(Provider):
    name = "openai"

    def __init__(self, model: str | None = None) -> None:
        from openai import OpenAI

        self.model = model or os.environ.get("OPENAI_MODEL", "gpt-5.5")
        self.client = OpenAI()  # picks up OPENAI_API_KEY

    def generate(self, prompt: str) -> GenerationResult:
        t0 = time.perf_counter()
        response = self.client.responses.create(
            model=self.model,
            input=prompt,
        )
        latency_s = time.perf_counter() - t0

        usage = getattr(response, "usage", None)
        input_tokens = getattr(usage, "input_tokens", 0) or 0
        output_tokens = getattr(usage, "output_tokens", 0) or 0

        in_details = getattr(usage, "input_tokens_details", None)
        cached_input_tokens = getattr(in_details, "cached_tokens", 0) or 0

        out_details = getattr(usage, "output_tokens_details", None)
        reasoning_tokens = getattr(out_details, "reasoning_tokens", 0) or 0

        return GenerationResult(
            text=response.output_text,
            input_tokens=input_tokens,
            cached_input_tokens=cached_input_tokens,
            output_tokens=output_tokens,
            reasoning_tokens=reasoning_tokens,
            latency_s=latency_s,
            model=self.model,
        )


class GeminiProvider(Provider):
    name = "gemini"

    def __init__(self, model: str | None = None) -> None:
        from google import genai

        api_key = os.environ.get("GEMINI_API_KEY")
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY is not set in the environment.")
        self.model = model or os.environ.get("GEMINI_MODEL", "gemini-3.1-pro-preview")
        self.client = genai.Client(api_key=api_key)

    def generate(self, prompt: str) -> GenerationResult:
        t0 = time.perf_counter()
        response = self.client.models.generate_content(
            model=self.model,
            contents=prompt,
        )
        latency_s = time.perf_counter() - t0

        text = response.text
        if text is None:
            raise RuntimeError(f"Gemini returned no text. Full response: {response!r}")

        meta = getattr(response, "usage_metadata", None)
        prompt_count = getattr(meta, "prompt_token_count", 0) or 0
        total_count = getattr(meta, "total_token_count", 0) or 0
        thoughts = getattr(meta, "thoughts_token_count", 0) or 0
        cached = getattr(meta, "cached_content_token_count", 0) or 0

        # Output billed = everything that isn't the prompt. This captures
        # both the visible candidate text and the (separately-counted) hidden
        # reasoning tokens that Gemini 3 still bills for.
        output_tokens = max(total_count - prompt_count, 0)

        return GenerationResult(
            text=text,
            input_tokens=prompt_count,
            cached_input_tokens=cached,
            output_tokens=output_tokens,
            reasoning_tokens=thoughts,
            latency_s=latency_s,
            model=self.model,
        )


class ClaudeProvider(Provider):
    name = "claude"

    def __init__(self, model: str | None = None) -> None:
        from anthropic import Anthropic

        api_key = os.environ.get("ANTHROPIC_API_KEY")
        if not api_key:
            raise RuntimeError("ANTHROPIC_API_KEY is not set in the environment.")
        self.model = model or os.environ.get("ANTHROPIC_MODEL", "claude-opus-4-7")
        # Output cap for the Messages API. Lean files + repair messages stay
        # well under this; the proposer prompts are large but the response is
        # the small piece. Override with ANTHROPIC_MAX_TOKENS if needed.
        self.max_tokens = int(os.environ.get("ANTHROPIC_MAX_TOKENS", "8192"))
        self.client = Anthropic(api_key=api_key)

    def generate(self, prompt: str) -> GenerationResult:
        t0 = time.perf_counter()
        response = self.client.messages.create(
            model=self.model,
            max_tokens=self.max_tokens,
            messages=[{"role": "user", "content": prompt}],
        )
        latency_s = time.perf_counter() - t0

        # Concatenate all text blocks. Non-text blocks (tool_use, thinking)
        # are skipped here since the orchestrator only consumes plain text.
        text_parts: list[str] = []
        for block in response.content:
            if getattr(block, "type", None) == "text":
                text_parts.append(block.text)
        text = "".join(text_parts)
        if not text:
            raise RuntimeError(f"Claude returned no text. Full response: {response!r}")

        usage = response.usage
        input_tokens = getattr(usage, "input_tokens", 0) or 0
        output_tokens = getattr(usage, "output_tokens", 0) or 0
        cached_input_tokens = getattr(usage, "cache_read_input_tokens", 0) or 0
        # Standard Messages API does not report a separate hidden-CoT token
        # count unless extended thinking is enabled, so leave at 0.
        reasoning_tokens = 0

        return GenerationResult(
            text=text,
            input_tokens=input_tokens,
            cached_input_tokens=cached_input_tokens,
            output_tokens=output_tokens,
            reasoning_tokens=reasoning_tokens,
            latency_s=latency_s,
            model=self.model,
        )


def get_provider(name: str) -> Provider:
    name = name.lower()
    if name in {"openai", "gpt", "gpt-5.5"}:
        return OpenAIProvider()
    if name in {"gemini", "google", "gemini-3", "gemini-3.1-pro-preview"}:
        return GeminiProvider()
    if name in {"claude", "anthropic", "claude-opus", "claude-opus-4-7"}:
        return ClaudeProvider()
    raise ValueError(
        f"Unknown provider: {name!r}. Use 'openai', 'gemini', or 'claude'."
    )
