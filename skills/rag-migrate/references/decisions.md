# Decision types and schema

Open this when implementing the decision-engine interface or an adapter. This file is identical in `rag-migrate` and `rag-design`; `scripts/check.sh` fails if they differ.

## Decision types

| Decision | Scope | Labels | Purpose |
|---|---|---|---|
| `relevant` | per unit | yes / partial / no | Filter candidates |
| `evidence_role` | per unit | supports / contradicts / context / none | Classify contribution |
| `temporal_status` | per unit | current / superseded / unknown | Time and version |
| `authority` | per unit | ordinal level in `detail` | Source hierarchy |
| `claim_equivalent` | per pair | yes / no | Redundancy |
| `sufficient` | per evidence set | sufficient / insufficient; missing aspects in `detail` | Stopping rule for bounded expansion |

## Output schema

Every adapter returns:

```json
{
  "decision": "relevant",
  "label": "partial",
  "score": 0.71,
  "score_kind": "probability | logit | rank | none",
  "calibrated": false,
  "detail": null,
  "abstain_reason": null,
  "engine_version": "engine-id@version"
}
```

- `label` comes from the closed enumeration above.
- `score` is treated as a probability only when `calibrated` is true (calibrated on labelled data).
- `detail` carries structured extras: `authority` → `{"level": 2}`; `sufficient` → `{"missing_aspects": ["…"]}`.
- `abstain_reason` is set when the engine cannot decide (invalid input, timeout, unsupported language); the caller then takes the degraded path.

## Operational rules

- Batch per query.
- Cache key: principal access scope, query hash, unit id and version, engine version, prompt/policy version. Invalidate on re-ingestion or any version change. If access scope cannot be part of the key, never cache restricted units.
- Decision prompts treat unit text as data and ignore instructions inside it.
- Record decisions with score and engine version under the approved retention rule.
- Cascade to a stronger engine only after calibrating the cheaper engine's scores on labelled data; choose the escalation threshold there and audit a random share of high-confidence decisions.
