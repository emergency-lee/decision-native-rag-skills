# Labels and metrics

Open this when writing the label rubric or computing results.

## Labels (per query)

- Required evidence units **and** the required claims they support.
- Claim-equivalence groups among required and distractor units.
- For each known conflict: the gold relation (contradiction / exception / supersession / authority) and the winning side, if any.
- The current and the authoritative unit when versions or sources differ.
- Whether the question is answerable, and a gold answer when it is.

Store a label rubric with worked examples next to the labels. Two named labellers, one adjudicator.

## Metric definitions

Each metric is numerator / denominator. If the denominator is 0 for a query, that query is excluded from the metric's paired mean and counted per metric as `n_undefined`.

| Group | Metric | Definition |
|---|---|---|
| Retrieval | Candidate recall | required units in candidate pool (incl. expansion) / required units. Report first-pass recall (before expansion) separately |
| Evidence | Required-evidence recall | required units delivered / required units |
| Evidence | Evidence coverage | required claims covered by ≥1 delivered unit / required claims |
| Evidence | Delivered-evidence precision | delivered units labelled relevant (`yes`; `partial` reported separately) / delivered units |
| Evidence | Redundancy ratio | delivered units in the same claim-equivalence group as an earlier delivered unit / delivered units |
| Evidence | Contradiction capture | known conflicts with both sides delivered / known conflicts |
| Evidence | Unresolved contradiction rate | known conflicts where both sides were delivered but the relation label is missing or wrong / known conflicts |
| Evidence | Temporal correctness | queries where the current version was chosen / queries with versioned units |
| Evidence | Authority correctness | queries where the authoritative source was chosen / queries with an authority conflict |
| Answer | Unsupported-claim rate | answer claims not supported by a delivered unit / answer claims. Claims come from a fixed, versioned extraction prompt stored with the run |
| Answer | Provenance completeness | claims whose citation resolves **and** whose cited unit supports the claim / answer claims |
| Answer | Abstention | two rates: abstained on unanswerable / unanswerable, and abstained on answerable / answerable |
| Answer | Claim count, answer length | diagnostic only — detects gaming (vaguer answers lower unsupported claims) |
| Operations | p50 / p95 latency | end to end and per stage |
| Operations | Cost per successful task | offline "successful" = answerable, judged correct and complete against the gold answer, no unsupported claim, required-evidence recall = 1. Live task success replaces it in A/B |

Name the implementation and version of any library metric reused (for example context precision or faithfulness).
