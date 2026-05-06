# Benchmarks

Cross-model comparison results, with the caveats that keep them
directional rather than significant.

## Three-way proposer/critic study

Same 10 hard examples (numbers `34, 36, 37, 38, 41, 42, 45, 47, 48,
50` from `examples/`), three pairings:

| Run | Proposer | Critic |
|-----|----------|--------|
| **G** | gemini-3.1-pro-preview | gpt-5.5 |
| **C** | claude-opus-4-7 | gpt-5.5 |
| **O** | gpt-5.5 | claude-opus-4-7 |

### Per-example outcomes

`Lean k` = accepted on attempt `k` (so `Lean 0` is one-shot).
`FAIL` = `sorryAx` after the 3-repair budget.

| # | Example | G | C | O |
|---|---|---|---|---|
| 34 | parity_xor | WEAK (Lean 0) | **PASS** (Lean 0) | **PASS** (Lean 2) |
| 36 | lcm_two | WEAK (Lean 1) | WEAK (Lean 0) | **PASS** (Lean 2) |
| 37 | pow_mod_small | WEAK (Lean 1) | WEAK (Lean 0) | **PASS** (Lean 0) |
| 38 | divmod_pair | WEAK (Lean 1) | WEAK (Lean 0) | **PASS** (Lean 0) |
| 41 | bit_count8 | WEAK (Lean 0) | WEAK (Lean 0) | WEAK (Lean 0) |
| 42 | is_power_of_two | WEAK (Lean 2) | **FAIL** (3) | **FAIL** (3) |
| 45 | list_filter_even | WEAK (Lean 0) | WEAK (Lean 0) | WEAK (Lean 0) |
| 47 | list_drop_while_pos | WEAK (Lean 1) | **PASS** (Lean 1) | **PASS** (Lean 0) |
| 48 | list_zip_min | WEAK (Lean 0) | WEAK (Lean 0) | **PASS** (Lean 3) |
| 50 | list_unique | WEAK (Lean 1) | **FAIL** (3) | WEAK (Lean 3) |

### Headline numbers

|  | G (gemini → gpt) | C (claude → gpt) | O (gpt → claude) |
|---|---|---|---|
| Lean acceptance | **10/10** | 8/10 | 9/10 |
| First-try Lean accept | 4/10 | **7/10** (of 8) | 5/10 (of 9) |
| Critic PASS | 0/10 | 2/10 | **6/10** |
| Total wall-clock (10 runs) | ~2313s (~38.5 min) | **~510s (~8.5 min)** | ~1817s (~30.3 min) |

## What the numbers actually mean

**Theorem strength is mostly a proposer signal.** GPT-5.5 with high
reasoning naturally aims at tight functional specs — importing
library lemmas like `Nat.lcm`, defining auxiliary helpers like
`pythonFloorDiv` / `pythonModulo` to express Python semantics. Gemini
and Claude default to easier targets: definitional unfolds, range
bounds, set-membership-instead-of-list-equality. The difference shows
up directly in critic-PASS rates: 0 / 2 / 6 out of 10.

**Lean closure is also a proposer signal — Gemini wins it.** It was
the only proposer to close `42_is_power_of_two` (using
`Classical.choice`) and `50_list_unique` (with an accumulator-spec
equivalence). Where Gemini fails is theorem strength: 0/10 PASS on
this hard slice, even with 10/10 Lean acceptance. Lean acceptance
without theorem strength is exactly the failure mode the critic
gate exists to catch.

**First-try Lean acceptance is a *style* signal.** Claude one-shots
most things it solves; GPT routinely needs 2–3 repair rounds. The
difference is mostly tactic-shape pickiness, not correctness.

**The four shared failures (41, 42, 45, 50) are the real "hard"
slice.** All three proposers fall into the same trap on the same
examples — that's the strongest signal the **prompt itself** is the
bottleneck on these problems, not any single model. WEAK reasons
across runs are nearly identical: `result ≤ 8`-style bounds for
`bit_count8`, set membership instead of list equality for
`list_filter_even`, and so on.

**Latency gap is mostly reasoning tokens.** GPT and Gemini both burn
4–8k reasoning tokens per call on hard examples; Claude does not (no
separate hidden-CoT bill in the standard Messages API). That
explains most of the ~4.5× wall-clock gap between Claude and the
other two.

## Cost/latency snapshot (single example)

From `examples/01_insecure_compare/pipeline_gemini_openai.log` —
gemini-3.1-pro-preview proposer + gpt-5.5 critic, 1 repair round:

```
[translate] in=661, out=18892, reasoning 18530, 140.95s  (gemini)
[repair_0]  in=735, out=7615,  reasoning 7281,  57.08s  (gemini)
[critic]    in=908, out=384,   reasoning 304,   10.86s  (gpt-5.5)
LLM totals: input=2304, output=26891 (reasoning 26115)
LLM wall:   208.88s
Lean:       5.26s across 2 compile attempts
Pipeline wall-clock: 214.80s
```

Output is dominated by reasoning tokens; visible Lean text is a
small fraction of the bill. Cost estimation requires filling in
`PRICING` in `verify/llm.py` with current per-1M-token rates.

## Suggested ensemble strategy

```
order: gpt(claude-critic) → gemini(gpt-critic) → claude(gpt-critic)
```

- **GPT-5.5 first**: highest theorem-strength rate (6/10 PASS on the
  hard slice), modest cost. Accept on PASS, otherwise pass to Gemini.
- **Gemini second when GPT fails on Lean (e.g. 42, 50)**: it grinds
  through structural-induction proofs better.
- **Claude as a fast WEAK-detector / cheap baseline**: ~4.5× faster
  than Gemini, useful for sweeping large suites.

A prompt-level fix that targets the four shared failures —
explicitly demanding "your theorem must determine the function value
at every input" — is probably more valuable than the ensemble,
though, since the WEAK reasons across runs are nearly identical.

## Caveats — why these are directional

- **Sample size 10**, single trial each. Pass@k isn't measured.
  Read everything as directional, not significant.
- **Critic confound.** G and C use gpt-5.5 critic; O uses Claude
  critic. Some of O's PASS-rate lift could be a more lenient critic.
  Cross-checks (verdicts agree on examples both critics evaluated;
  WEAK reasons of similar specificity) suggest this is not the
  dominant effect, but a clean follow-up would re-run O with gpt-5.5
  critic.
- **Easy slice not in this table.** On the easier 11–30 set, Gemini's
  PASS rate was 20/20 — the hard slice is the diagnostic, not the
  whole story. On easy problems, all three proposers are roughly
  equivalent on theorem strength.
- **No mutation-kill.** A theorem that a buggy implementation also
  satisfies is still a vacuous theorem. The critic catches some of
  these; mutation-kill (see [roadmap.md](roadmap.md)) would catch
  more, mechanically.

## Source data

- Gemini logs: `examples/<dir>/pipeline_gemini_openai.log`
- Per-example artifacts: `examples/<dir>/last_lean_<provider>.lean`,
  `last_proposer_<provider>.txt`, `last_critic_<critic>.txt`
