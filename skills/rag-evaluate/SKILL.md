---
name: rag-evaluate
description: Compare a frozen baseline RAG pipeline against a named candidate with paired measurements and rollout gates — offline replay, then human-approved shadow, canary, and A/B — covering evidence recall, redundancy, contradiction handling, unsupported claims, provenance, latency, and cost. Use only when the user asks for a baseline-versus-candidate comparison or rollout gates. Not a general RAG audit, not a single-bug diagnosis, and not "evaluate/improve my RAG" without a candidate change — ask which is wanted first.
---

# rag-evaluate

Decide with measurements whether a candidate RAG pipeline should replace the baseline. The default answer is **keep the baseline** until the candidate passes every gate.

## Ground rules

- **Inspect the host repository first** and summarise how requests flow and what is already logged.
- **Paired comparisons only.** Same queries, corpus version, index snapshot, and answer model where possible. Change one thing at a time.
- **Pre-declare** the primary metric, guardrails, thresholds, and analysis before looking at candidate results.
- **An LLM judge is a sensor, not a verdict.** It must pass the calibration rule below before its numbers enter a gate.
- **Build the harness inside the target project**, in its language and test tooling. No new repository or service.
- **Offline replay is the last autonomous stage.** Shadow, canary, and A/B each need recorded human approval. So does sending current or historical production data to a provider not already approved, even during offline replay.
- **Private data stays private.** Query sets, labels, traces, and reports contain real queries and answers: store them in the user's private environment and never commit them to a public repository.

## Ask the human (checkpoints)

Start inspection and the pilot immediately. Ask items 1 and 2 before labelling begins and record any default you propose. Item 3 is asked just before each live stage and never defaulted.

1. Who the two labellers are, by when, and who adjudicates disagreements. LLM-drafted labels are allowed only if a named human reviews them, and the report must say so.
2. The primary metric, guardrails, numeric threshold for each gate, and the release-set size (propose defaults; see *Default gates*).
3. For each live stage: approval naming environment, traffic share, window, guardrails, data boundary (which provider sees which data), expected extra cost, and rollback owner.

## Stage 1 — Offline frozen replay

1. **Query set.** Sample from real logs when available; stratify by intent, difficulty, and freshness. Add adversarial cases: near-duplicate sources, conflicting sources, superseded documents, unanswerable questions. With no logs (cold start), draft queries from corpus sections and have the named human prune them.
2. **Labels (per query).** Required evidence units **and** the required claims they support; claim-equivalence groups among required and distractor units; for each known conflict the gold relation (contradiction / exception / supersession / authority) and the winning side if any; the current and authoritative unit when versions differ; whether the question is answerable. Store a label rubric with examples.
3. **Size.** 50–200 labelled queries is a pilot: its verdict can only be *iterate* or *keep the baseline*. A *ship* verdict needs the release set, sized by a power calculation on the primary metric (state baseline rate and minimum detectable effect), or ≥300 queries when no estimate exists. Report a stratum's interval only if it has ≥30 queries.
4. **Runs.** Execute baseline and candidate on the frozen snapshot; store candidates, decisions, delivered set, answer, latency, and cost per query.
5. **Analysis.** Paired per-query differences (candidate − baseline), 95% percentile bootstrap with ≥2000 resamples; resample by cluster when queries share a user or session. Only the primary metric and guardrails decide; everything else is diagnostic. If many metrics or strata are tested, apply Holm correction or label them exploratory. Queries where either arm abstains are reported separately, not dropped.

## Metrics

Each metric defines numerator / denominator; if the denominator is 0 the query is excluded from that metric's paired mean and reported per metric as `n_undefined`.

| Group | Metric | Definition |
|---|---|---|
| Retrieval | Candidate recall | required units in candidate pool (incl. expansion) / required units |
| Evidence | Required-evidence recall | required units delivered / required units |
| Evidence | Evidence coverage | required claims covered by ≥1 delivered unit / required claims |
| Evidence | Delivered-evidence precision | delivered units labelled relevant (`yes`; `partial` reported separately) / delivered units |
| Evidence | Redundancy ratio | delivered units in the same claim-equivalence group as an earlier delivered unit / delivered units |
| Evidence | Contradiction capture | known conflicts with both sides delivered / known conflicts |
| Evidence | Unresolved contradiction rate | known conflicts where both sides were delivered but the relation label is missing or wrong / known conflicts |
| Evidence | Temporal correctness | queries where the current version was chosen / queries with versioned units |
| Evidence | Authority correctness | queries where the authoritative source was chosen / queries with an authority conflict |
| Answer | Unsupported-claim rate | answer claims not supported by a delivered unit / answer claims. Claims are extracted with a fixed, versioned extraction prompt stored with the run |
| Answer | Provenance completeness | claims whose citation resolves **and** whose cited unit supports the claim / answer claims |
| Answer | Abstention | report two rates: abstained on unanswerable / unanswerable, and abstained on answerable / answerable |
| Answer | Claim count, answer length | diagnostic, to detect gaming (vaguer answers lower unsupported claims) |
| Operations | p50 / p95 latency; cost per successful task | offline "successful" = answerable, judged correct and complete against the gold answer by a human or a calibrated judge, no unsupported claim, required-evidence recall = 1; live task success replaces it in A/B |

Name the implementation and version of any library metric reused (for example context precision or faithfulness).

## Judge calibration

- Two human labellers on ≥50 items; report their agreement.
- The judge is blind to which arm produced the output.
- Report the judge's confusion matrix and per-class errors against the human labels, especially on unsafe classes.
- The judge enters a gate only if its agreement with humans meets the pre-declared floor (default Cohen's κ ≥ 0.6).

## Default gates

Thresholds are proposed in `EVAL_PLAN.md` and approved by the owner. "Improve" and "fall" mean by at least the declared margin with the 95% interval excluding zero.

| Dimension | Gate | Stage |
|---|---|---|
| Required-evidence recall | Improves, or no regression when baseline is already high | Offline |
| Delivered-evidence precision | Improves or stays within agreed tolerance | Offline |
| Redundancy ratio | Falls by the declared margin (default 20% relative) | Offline |
| Unresolved contradiction rate | Falls by the declared margin | Offline |
| Unsupported-claim rate | Must not regress | Offline, canary |
| Provenance completeness | Must not regress | Offline |
| p95 latency | Within SLO or an approved trade-off | All |
| Cost per successful task | Improves, or the quality gain is justified in writing | Offline, A/B |
| User / task success | Improves in A/B before full rollout | A/B |

## Stage 2 — Shadow (approval required)

The candidate runs on live traffic; users still get the baseline. Live payloads go only to engines inside the approved data boundary. Compare distributions (latency, cost, abstention rate, evidence-set size), review sampled disagreements, and confirm the offline set represents live traffic.

## Stage 3 — Canary (approval required)

Route a small share of traffic (for example 1–5%) with automatic rollback. Declare a minimum window and a minimum number of judged answers (for example ≥200) before any guardrail verdict; guardrails are absolute rates over that window.

## Stage 4 — A/B (approval required)

Sticky random assignment per user or session. Record baseline rate, minimum detectable effect, alpha, and power; compute the sample size. Check sample-ratio mismatch. Use a fixed horizon with no peeking, or a sequential method declared in advance.

## Deliverables

- `EVAL_PLAN.md`: strata table, label schema and rubric, labeller and adjudicator, primary metric, guardrails and thresholds, judge calibration plan, stage plan with approvals.
- Replay harness and stored run artefacts per version.
- `EVAL_REPORT.md`: paired results with intervals, per-stratum tables, failure examples, gate verdicts, and a recommendation: ship, iterate, or keep the baseline.

All three are private artefacts.

## Stop conditions

Report these as blockers instead of producing numbers:

- the baseline cannot be reproduced on the frozen snapshot;
- the judge misses its calibration floor;
- the query set does not cover the failure modes the candidate targets;
- no named human owns the labels.
