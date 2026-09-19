# Evaluation Protocol

| Stage | Traffic | Serves users | Exit criterion |
|---|---|---|---|
| Offline frozen replay (pilot, then release set) | Labelled query set | No | Primary metric and guardrails pass their declared thresholds (paired 95% CI) |
| Shadow (human approval) | Live, mirrored | Baseline only | Live distributions match offline expectations; disagreements reviewed |
| Canary (human approval) | Small share (e.g. 1–5%) | Candidate for the share | No guardrail breach over the agreed window and minimum judged sample |
| A/B (human approval) | Randomised, sticky | Both arms | Pre-declared primary metric improves at the planned sample size; guardrails hold; no sample-ratio mismatch |

## Required artefacts per run

- Corpus, index, model, prompt, and engine versions
- Per query: candidate ids and scores, decisions with score, score_kind, and calibration status, delivered set, answer, citations, latency, cost
- Judge model and version, with its agreement rate against human labels

## Details

Metric definitions, label spec, analysis rules, judge calibration, and canary/A/B sampling live inside the skill so they travel with it:

- `skills/rag-evaluate/references/metrics.md`
- `skills/rag-evaluate/references/statistics.md`

All run artefacts contain real queries and stay in the evaluated system's private environment.
