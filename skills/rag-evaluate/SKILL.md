---
name: rag-evaluate
description: Compare a frozen baseline RAG pipeline against a named candidate with paired measurements and rollout gates — offline replay, then human-approved shadow, canary, and A/B — covering evidence recall, redundancy, contradiction handling, unsupported claims, provenance, latency, cost, and optional compiled-state cold/warm reuse. Use only when the user asks for a baseline-versus-candidate comparison or rollout gates. Not a general RAG audit, not a single-bug diagnosis, and not "evaluate/improve my RAG" without a candidate change — ask which is wanted first.
---

# rag-evaluate

Decide with measurements whether a candidate RAG pipeline should replace the baseline. The default answer is **keep the baseline** until the candidate passes every gate.

## Ground rules

- **Inspect the host repository first** and summarise how requests flow and what is already logged.
- **Paired comparisons only.** Same queries, corpus version, index snapshot, and answer model where possible. Change one thing at a time.
- **Pre-declare** the primary metric, guardrails, thresholds, and analysis before looking at candidate results.
- **An LLM judge is a sensor, not a verdict.** It enters a gate only after calibration ([references/statistics.md](references/statistics.md)).
- **Build the harness inside the target project**, in its language and test tooling. No new repository or service.
- **Offline replay is the last autonomous stage.** Shadow, canary, and A/B each need recorded human approval. So does sending current or historical production data to a provider not already approved, even during offline replay.
- **Private data stays private.** Query sets, labels, traces, and reports contain real queries and answers: keep them in the user's private environment, never in a public repository.

## Separating effects

When a candidate combines a decision layer and state/cache reuse, the arms are **A** baseline, **B** decision layer only, **C** state reuse only, **D** both. If the report will attribute gains to each component, all four arms are required and the contrasts are pre-declared; if only the bundle is evaluated, compare D−A only and make no per-component claim. This is the declared exception to "change one thing at a time". For compiled-state candidates, measure cold and warm paths separately: a cache hit is a workload condition, not a quality result.

## Ask the human (checkpoints)

Start inspection and the pilot immediately. Ask items 1 and 2 before labelling begins and record any default you propose. Item 3 is asked just before each live stage and never defaulted.

1. Who the two labellers are, by when, and who adjudicates. LLM-drafted labels are allowed only if a named human reviews them, and the report says so.
2. Primary metric, guardrails, gate thresholds, and release-set size.
3. For each live stage: environment, traffic share, window, guardrails, data boundary (which provider sees which data), expected extra cost, rollback owner.

## Stage 1 — Offline frozen replay

1. **Query set.** Sample from real logs when available; stratify by intent, difficulty, and freshness. Add adversarial cases: near-duplicates, conflicting sources, superseded documents, unanswerable questions. With no logs, draft queries from corpus sections and have the named human prune them.
2. **Labels.** Follow the label spec in [references/metrics.md](references/metrics.md).
3. **Pilot, then release set.** The pilot can only say *iterate* or *keep the baseline*; *ship* needs the powered release set ([references/statistics.md](references/statistics.md)).
4. **Runs.** Baseline and candidate on the frozen snapshot; store candidates, decisions, resolved scope and whether it was expanded, delivered set, per-unit verification result and reason, serving path (normal / degraded), answer, latency, and cost per query; for state reuse, cold/warm/cache status and state/manifest version.
5. **Analysis.** Paired differences with bootstrap intervals, primary metric and guardrails only, per the rules in [references/statistics.md](references/statistics.md).

Metric definitions: [references/metrics.md](references/metrics.md).

## Default gates

Thresholds are proposed in `EVAL_PLAN.md` and approved by the owner.

| Dimension | Gate | Stage |
|---|---|---|
| Required-evidence recall | Improves, or no regression when baseline is already high | Offline |
| Delivered-evidence precision | Improves or stays within agreed tolerance | Offline |
| Redundancy ratio | Falls by the declared margin | Offline |
| Unresolved contradiction rate | Falls by the declared margin | Offline |
| Unsupported-claim rate | Must not regress | Offline, canary |
| Provenance completeness | Must not regress | Offline |
| Delivered-set verification | Zero failures after the drop/expand loop | All |
| Source recovery (state reuse) | Every id the state path returns resolves to its correct authorised span (accuracy = 100%) | All |
| p95 latency | Within SLO or an approved trade-off | All |
| Cost per successful task | Improves, or the quality gain is justified in writing | Offline, A/B |
| User / task success | Improves in A/B before full rollout | A/B |

## Live stages (each needs its own approval)

- **Shadow** — candidate runs on live traffic, users still get the baseline. Live payloads go only to engines inside the approved data boundary. Compare distributions, review sampled disagreements, and confirm the offline set represents live traffic.
- **Canary** — a small share (for example 1–5%) with automatic rollback; minimum window and judged sample first.
- **A/B** — sticky random assignment, powered sample size, sample-ratio check, no peeking.

Sampling rules for canary and A/B: [references/statistics.md](references/statistics.md).

## Deliverables (all private)

- `EVAL_PLAN.md`: strata, label rubric, labellers and adjudicator, primary metric, guardrails and thresholds, judge calibration plan, stage plan with approvals.
- Replay harness and stored run artefacts per version.
- `EVAL_REPORT.md`: paired results with intervals, per-stratum tables, failure examples, gate verdicts, and a recommendation: ship, iterate, or keep the baseline.

## Stop conditions

Report these as blockers instead of producing numbers:

- the baseline cannot be reproduced on the frozen snapshot;
- the judge misses its calibration floor;
- the query set does not cover the failure modes the candidate targets;
- the compiled-state candidate cannot prove source recovery, freshness after invalidation, or tenant/cache isolation;
- no named human owns the labels.
