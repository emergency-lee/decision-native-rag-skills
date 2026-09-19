# Architecture Principles

1. **Resolve scope, then retrieve as broadly as the scope needs, decide explicitly.** An explicitly named document, collection, or tenant scope is preserved. Candidate generation (dense, sparse, filters) still optimises for recall inside that scope and inside ACL filters; delivered context stays small. Ambiguous scope is resolved before retrieval; insufficiency-driven widening is a bounded evidence-set loop. Relevance, sufficiency, redundancy, conflict, time, and authority remain separate, explicit decisions.
2. **Typed decisions, not prose.** Each decision returns an enumerated label and a score so software can branch on it without parsing text. A score is treated as a probability only after calibration on labelled data.
3. **Evidence sets, not Top-K lists.** The unit handed to the reasoning model is a set that is sufficient, non-redundant, and conflict-aware. Zero items is a valid set. Sufficiency is itself a typed, set-level decision and the stopping rule for bounded expansion.
4. **Confidence, set sufficiency, and deterministic validity are three separate gates.** A confident decision never implies that the evidence is sufficient or valid.
5. **Claim equivalence over text similarity.** Two passages that assert the same claim are redundant for context even if worded differently — keep one representative and retain the others as corroborating provenance. Two similar passages that disagree are both needed.
6. **Conflicts are labelled, not hidden.** Contradiction, exception, supersession, and authority difference are different relations and are handled differently.
7. **Time and authority are first-class metadata.** They are captured at ingestion, not inferred at answer time.
8. **Pluggable decision engine.** Hosted, local, open, proprietary, and cascaded engines sit behind one interface.
9. **Provenance end to end.** Every delivered unit and every answer claim can be traced to a source id and version.
10. **Deterministic verification after semantic selection.** Before reasoning, every delivered unit id must resolve to an authoritative source version/hash the principal may read (ACL re-checked at delivery), and the unit's locator/span must exist in that version. Failed units are dropped; if the set is then insufficient, re-enter bounded expansion (expand → sufficient → verify) within the same N-round budget, else abstain — newly expanded units are never delivered unverified. After the answer, every citation must resolve to a delivered, verified unit. Semantic engines choose; authoritative systems prove.
11. **Reusable model state is an optional accelerator, never the source of truth.** Prefix/KV cache or other compiled state may be used to decide if useful; citations always come from the source store.
12. **Measure before and after.** A change ships only when it beats a frozen baseline on pre-declared gates.
13. **Keep the baseline restorable.** Rollback is part of the design and is rehearsed before any live stage.
14. **Hot path vs control path.** Index repair, re-embedding, version reconciliation, and cache/state rebuild run off the query path and activate atomically. The query path has a defined degraded mode (frozen baseline if available, else lexical plus metadata retrieval, else plain Top-K; always inside ACL filters) when the decision layer times out or fails. Every path, degraded ones included, still passes deterministic verification; if the source store or ACL check is unavailable, abstain rather than serve unverified evidence.
15. **Authorization before judgement.** Access filters apply inside candidate generation; restricted units never reach decision engines, caches, or logs.
16. **Retrieved text is untrusted.** Decision and reasoning prompts separate instructions from unit text and ignore instructions inside units.
17. **Humans approve live exposure.** Offline replay is the last autonomous stage; shadow, canary, A/B, and sending production data to a new provider need recorded approval.

## Decision schema

The canonical decision types and output schema live in `skills/rag-migrate/references/decisions.md` (identical copy in `skills/rag-design/references/`). Each skill folder is self-contained so it works when installed on its own. The optional compiled-state path is specified in [`compiled-state.md`](compiled-state.md).
