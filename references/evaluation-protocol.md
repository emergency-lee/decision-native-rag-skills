# Evaluation Protocol

| Stage | Traffic | Serves users | Exit criterion |
|---|---|---|---|
| Offline frozen replay | Labelled query set | No | All offline gates pass with paired confidence intervals |
| Shadow | Live, mirrored | Baseline only | Live distributions match offline expectations; disagreements reviewed |
| Canary | Small share (e.g. 1–5%) | Candidate for the share | No guardrail breach over the agreed window |
| A/B | Randomised, sticky | Both arms | Pre-declared primary metric improves; guardrails hold |

## Required artefacts per run

- Corpus, index, model, prompt, and engine versions
- Per query: candidate ids and scores, decisions with probabilities, delivered set, answer, citations, latency, cost
- Judge model and version, with its agreement rate against human labels

## Paired analysis

Compute per-query differences (candidate − baseline) and report the mean with a bootstrap confidence interval, overall and per stratum. Report failure examples for every metric that regresses.

See `skills/rag-evaluate/SKILL.md` for metric definitions and default gates.
