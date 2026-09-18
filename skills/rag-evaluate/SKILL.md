---
name: rag-evaluate
description: Build and run a baseline-versus-candidate comparison for RAG systems — offline paired replay, shadow, canary, and A/B — measuring evidence recall, redundancy, contradiction handling, unsupported claims, provenance, latency, and cost. Use when the user explicitly asks to evaluate or compare a RAG change, set rollout gates, or prove a decision-native pipeline beats fixed Top-K. Not a general RAG audit or a single-bug diagnosis.
---

# rag-evaluate

Decide with measurements whether a candidate RAG pipeline should replace the baseline. The default answer is **keep the baseline** until the candidate passes every gate.

## Ground rules

- **Paired comparisons only.** Same queries, same corpus version, same index snapshot, same answer model where possible. Change one thing at a time.
- **Pre-declare metrics and thresholds** before looking at candidate results.
- **An LLM judge is a sensor, not a verdict.** Calibrate it against a human-labelled sample and report its agreement rate. Never ship on judge preference alone.
- **Build the harness inside the target project**, in its language and test tooling. No mandatory external runner.
- **Private data stays private.** Evaluation sets built from a user's system remain in that environment.

## Stage 1 — Offline frozen replay

1. **Query set.** Sample from real logs when available; stratify by intent, difficulty, and freshness. Add adversarial cases: near-duplicate sources, conflicting sources, superseded documents, questions with no answer in the corpus.
2. **Labels.** For each query, list the *required evidence* (source ids or claims), known contradictions, and whether abstention is correct. Start small (50–200 labelled queries) and grow.
3. **Runs.** Execute baseline and candidate on the frozen snapshot; store candidates, decisions, delivered context, answer, latency, and cost per query.
4. **Analysis.** Paired differences with confidence intervals (bootstrap is fine). Report per stratum, not only the average.

## Metrics

| Group | Metric | Definition |
|---|---|---|
| Retrieval | Candidate recall | Required evidence present in the candidate pool |
| Evidence | Required-evidence recall | Required evidence present in the delivered set |
| Evidence | Delivered-evidence precision | Delivered items that are relevant |
| Evidence | Redundancy ratio | Delivered items that are claim-equivalent to another delivered item |
| Evidence | Contradiction capture | Known conflicts where both sides were delivered |
| Evidence | Contradiction resolution accuracy | Correct relation label: contradiction, exception, supersession, authority |
| Evidence | Temporal / authority correctness | Current and authoritative source chosen when they differ |
| Answer | Unsupported-claim rate | Answer claims not backed by the delivered evidence |
| Answer | Correct abstention | Abstains when the corpus has no answer; answers when it does |
| Answer | Provenance completeness | Claims carrying a resolvable citation |
| Operations | p50 / p95 latency, cost per successful task | End to end, per stage |

Conventional measures such as context precision, context recall, and faithfulness can be reused where they fit; state which implementation and version was used.

## Default gates

| Dimension | Gate |
|---|---|
| Required-evidence recall | Improves, or no regression when baseline is already high |
| Delivered-evidence precision | Improves or stays within agreed tolerance |
| Redundancy | Falls materially |
| Unresolved contradictions | Fall materially |
| Unsupported claims | Must not regress |
| Provenance completeness | Must not regress |
| p95 latency | Within SLO or an explicitly approved trade-off |
| Cost per successful task | Improves, or the quality gain is justified in writing |

Adapt thresholds to the domain and record the reason for each change.

## Stage 2 — Shadow

The candidate runs on live traffic; users still get the baseline. Compare distributions (latency, cost, abstention rate, evidence-set size), sample disagreements for review, and confirm the offline set represents live traffic.

## Stage 3 — Canary

Route a small share of traffic (for example 1–5%) to the candidate with automatic rollback on guardrail breach: error rate, p95 latency, unsupported-claim sample rate, user complaints.

## Stage 4 — A/B

Sticky random assignment per user or session. One primary metric (task success or an agreed proxy) plus guardrails. Fix sample size and duration in advance; do not stop early on a good day.

## Deliverables

- `EVAL_PLAN.md`: strata, labels, metrics, thresholds, judge calibration, stage plan.
- Replay harness and stored run artefacts per version.
- `EVAL_REPORT.md`: paired results with intervals, per-stratum tables, failure examples, gate verdicts, and a clear recommendation: ship, iterate, or keep the baseline.

## Stop conditions

- The baseline cannot be reproduced on the frozen snapshot.
- Judge agreement with human labels is too low to trust.
- The query set does not cover the failure modes the candidate targets.

Report these as blockers instead of producing numbers.
