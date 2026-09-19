# Labels and metrics

Open this when writing the label rubric or computing results.

## Labels (per query)

- Required evidence units **and** the required claims they support.
- Claim-equivalence groups among required and distractor units.
- For each known conflict: the gold relation (contradiction / exception / supersession / authority) and the winning side, if any.
- The current and the authoritative unit when versions or sources differ.
- Whether the question is answerable, and a gold answer when it is.
- The gold scope (document, collection, tenant, or unspecified) when the query names one or a labeller can assign one.

Store a label rubric with worked examples next to the labels. Two named labellers, one adjudicator.

## Metric definitions

Each rate metric is numerator / denominator and names that denominator. If the denominator is 0 for a query, that query is excluded from the metric's paired mean and counted per metric as `n_undefined`. Operations and Compiled-state latency, TTFT, size, and rebuild-time rows are distributions (p50/p95 or equivalent), not ratios.

| Group | Metric | Definition |
|---|---|---|
| Retrieval | Candidate recall | required units in candidate pool (incl. expansion) / required units. Report first-pass recall (before expansion) separately |
| Retrieval | Scope accuracy | queries whose resolved scope matches the gold scope / queries with a gold scope |
| Retrieval | Scope expansion rate | queries whose search scope was widened beyond the explicit or first-resolved scope / queries |
| Evidence | Required-evidence recall | required units delivered / required units |
| Evidence | Evidence coverage | required claims covered by ≥1 delivered unit / required claims |
| Evidence | Delivered-evidence precision | delivered units labelled relevant (`yes`; `partial` reported separately) / delivered units |
| Evidence | Redundancy ratio | delivered units in the same claim-equivalence group as an earlier delivered unit / delivered units |
| Evidence | Contradiction capture | known conflicts with both sides delivered / known conflicts |
| Evidence | Unresolved contradiction rate | known conflicts where both sides were delivered but the relation label is missing or wrong / known conflicts |
| Evidence | Temporal correctness | queries where the current version was chosen / queries with versioned units |
| Evidence | Authority correctness | queries where the authoritative source was chosen / queries with an authority conflict |
| Evidence | Deterministic verification failure rate | delivered units that fail id, version, ACL, or span checks after the drop/expand loop / delivered units |
| Answer | Unsupported-claim rate | answer claims not supported by a delivered unit / answer claims. Claims come from a fixed, versioned extraction prompt stored with the run |
| Answer | Provenance completeness | claims whose citation resolves **and** whose cited unit supports the claim / answer claims |
| Answer | Abstention | two rates: abstained on unanswerable / unanswerable, and abstained on answerable / answerable |
| Answer | Claim count, answer length | diagnostic only — detects gaming (vaguer answers lower unsupported claims) |
| Operations | p50 / p95 latency | diagnostic distribution, end to end and per stage |
| Operations | Cost per successful task | offline "successful" = answerable, judged correct and complete against the gold answer, no unsupported claim, required-evidence recall = 1. Live task success replaces it in A/B |
| Operations | Fallback (degraded-mode) rate | queries served by the degraded path / queries |
| Compiled state | Cold / warm latency | diagnostic distribution: cold = parse + tokenize + prefill/compile + query; warm = compatible state already available. Report TTFT separately |
| Compiled state | Cache hit / miss | hits (or misses) / state lookup attempts |
| Compiled state | Eviction rate | evicted state entries / state entries inserted in the window |
| Compiled state | State footprint | diagnostic: bytes plus RAM/VRAM pressure and concurrency capacity |
| Compiled state | Invalidation / rebuild time | diagnostic distribution: time from detected change to safe state replacement |
| Compiled state | Stale-state rate | compiled-state queries affected by content, ACL, version, model, or policy changes not yet reflected in state / compiled-state queries; also report incident count |
| Compiled state | Source-recovery accuracy | unit ids returned by the state path that resolve to the correct authorised source spans / unit ids returned by the state path |

Name the implementation and version of any library metric reused (for example context precision or faithfulness).

## Compiled-state formulas

For compile cost C, baseline per-query cost R, and warm compiled-state cost K:

```text
N = C / (R - K), when R > K
```

This is an amortisation estimate only. Include cache misses, invalidation, state storage, security controls, and source recovery in the workload model. A low warm-query latency alone is not a release gate. A cache hit is a workload condition, not a quality result.
