# Architecture Principles

1. **Retrieve broadly, decide explicitly.** Candidate generation (dense, sparse, filters) optimises for recall. Relevance, sufficiency, redundancy, conflict, time, and authority are separate, explicit decisions.
2. **Typed decisions, not prose.** Each decision returns an enumerated label with a probability so software can branch on it without parsing text.
3. **Evidence sets, not Top-K lists.** The unit handed to the reasoning model is a set that is sufficient, non-redundant, and conflict-aware. Zero items is a valid set.
4. **Claim equivalence over text similarity.** Two passages that assert the same claim are redundant even if worded differently; two similar passages that disagree are both needed.
5. **Conflicts are labelled, not hidden.** Contradiction, exception, supersession, and authority difference are different relations and are handled differently.
6. **Time and authority are first-class metadata.** They are captured at ingestion, not inferred at answer time.
7. **Pluggable decision engine.** Hosted, local, open, proprietary, and cascaded engines sit behind one interface.
8. **Provenance end to end.** Every delivered unit and every answer claim can be traced to a source id and version.
9. **Measure before and after.** A change ships only when it beats a frozen baseline on pre-declared gates.
10. **Keep the baseline restorable.** Rollback is part of the design.
