# code2lean — docs index

Curated design and methodology notes. The top-level `README.md` covers
"what it is and how to run it"; these files cover **why it's built
this way** and **what works / doesn't work yet**.

| File | Read it for |
|------|-------------|
| [architecture.md](architecture.md) | The design thoughts: trust model, proposer/verifier split, the five validation gates, anti-spoofing. |
| [pipeline.md](pipeline.md) | How the orchestrator runs end-to-end: extract → translate → compile/repair → axiom gate → diff-test → critic. |
| [example-walkthrough.md](example-walkthrough.md) | A single example (`34_parity_xor`) traced through every gate, with the Lean output and the critic verdict. |
| [benchmarks.md](benchmarks.md) | Three-way proposer comparison (Gemini/Claude/GPT), what the numbers mean, and the caveats that keep the result directional. |
| [scope-and-limits.md](scope-and-limits.md) | What kind of source code the pipeline can verify today, and what it would take to extend beyond Python. |
| [roadmap.md](roadmap.md) | Metrics that aren't instrumented yet (mutation-kill, pass@k, distinguishability) and the path to vulnerability finding. |

The original HMAC security demo lives at the top of the repo
(`source/`, `tests/`, `RepoVerify/TokenVerify.lean`) — that's the
motivating story, not part of the generic pipeline. The notes here
focus on the pipeline.
