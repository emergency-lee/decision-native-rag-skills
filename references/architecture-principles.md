# Architecture Principles

1. **Retrieve broadly, decide explicitly.** Candidate generation (dense, sparse, filters) optimises for recall. Relevance, sufficiency, redundancy, conflict, time, and authority are separate, explicit decisions.
2. **Typed decisions, not prose.** Each decision returns an enumerated label and a score so software can branch on it without parsing text. A score is treated as a probability only after calibration on labelled data.
3. **Evidence sets, not Top-K lists.** The unit handed to the reasoning model is a set that is sufficient, non-redundant, and conflict-aware. Zero items is a valid set. Sufficiency is itself a typed, set-level decision and the stopping rule for bounded expansion.
4. **Claim equivalence over text similarity.** Two passages that assert the same claim are redundant for context even if worded differently — keep one representative and retain the others as corroborating provenance. Two similar passages that disagree are both needed.
5. **Conflicts are labelled, not hidden.** Contradiction, exception, supersession, and authority difference are different relations and are handled differently.
6. **Time and authority are first-class metadata.** They are captured at ingestion, not inferred at answer time.
7. **Pluggable decision engine.** Hosted, local, open, proprietary, and cascaded engines sit behind one interface.
8. **Provenance end to end.** Every delivered unit and every answer claim can be traced to a source id and version.
9. **Measure before and after.** A change ships only when it beats a frozen baseline on pre-declared gates.
10. **Keep the baseline restorable.** Rollback is part of the design and is rehearsed before any live stage.
11. **Authorization before judgement.** Access filters apply inside candidate generation; restricted units never reach decision engines, caches, or logs.
12. **Retrieved text is untrusted.** Decision and reasoning prompts separate instructions from unit text and ignore instructions inside units.
13. **Humans approve live exposure.** Offline replay is the last autonomous stage; shadow, canary, A/B, and sending production data to a new provider need recorded approval.

## Shared decision schema

Every decision engine adapter returns:

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

`label` values come from a closed enumeration per decision type. `detail` carries structured extras: `authority` → `{"level": 2}`, `sufficient` → `{"missing_aspects": ["…"]}`. `abstain_reason` is set when the engine cannot decide (invalid input, timeout, out-of-scope language); the caller then applies the degraded path.
