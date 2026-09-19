# Decision-engine selection

Open this when choosing or replacing a decision engine.

## Labels

Derive decision labels from the query labels (units, equivalence groups, conflicts) instead of collecting them separately. Sample `claim_equivalent` pairs within similarity buckets. Pilot with ~50 per decision type; choose with ≥200 per type and ≥100 sets for `sufficient` (*starting values*, tune per project).

## Criteria

Accuracy · calibration (reliability plot or ECE) · cost · p95 latency · language coverage · privacy and data residency · licence · availability · behaviour on adversarial units.

## Candidates

Low-cost typed decision models, local open models that score options without generating prose, rerankers, and general LLMs as fallback. Read each candidate's current documentation before writing an adapter; record URL and access date.

## Cascade and degraded mode

- Cascade only with calibrated scores; choose the escalation threshold on the labelled sample.
- Define a degraded mode (plain Top-K) for when the engine is unavailable or rate-limited, and test it.
