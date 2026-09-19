# Evaluation Protocol

| Stage | Traffic | Serves users | Exit criterion |
|---|---|---|---|
| Offline frozen replay | Labelled query set | No | Primary metric and guardrails pass their declared thresholds (paired 95% CI) |
| Shadow (human approval) | Live, mirrored | Baseline only | Live distributions match offline expectations; disagreements reviewed |
| Canary (human approval) | Small share (e.g. 1–5%) | Candidate for the share | No guardrail breach over the agreed window and minimum judged sample |
| A/B (human approval) | Randomised, sticky | Both arms | Pre-declared primary metric improves at the planned sample size; guardrails hold; no sample-ratio mismatch |

## Required artefacts per run

- Corpus, index, model, prompt, and engine versions
- Per query: candidate ids and scores, decisions with probabilities, delivered set, answer, citations, latency, cost
- Judge model and version, with its agreement rate against human labels

## Paired analysis

Compute per-query differences (candidate − baseline) and report the mean with a 95% percentile bootstrap interval (≥2000 resamples, clustered by user or session when queries repeat). Only the pre-declared primary metric and guardrails gate; other metrics are diagnostic. Report strata with ≥30 queries; report abstentions separately. Report failure examples for every metric that regresses.

All run artefacts contain real queries and stay in the evaluated system's private environment.

See `skills/rag-evaluate/SKILL.md` for metric definitions and default gates.
