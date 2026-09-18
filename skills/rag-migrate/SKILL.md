---
name: rag-migrate
description: Incrementally migrate an existing RAG system from fixed Top-K retrieval to a decision-native evidence pipeline (broad retrieval → semantic decisions → evidence set → reasoning), with a frozen baseline, shadow/canary rollout, and rollback. Use when the user explicitly asks to migrate, refactor, or upgrade an existing RAG pipeline toward a decision layer or evidence-set construction. Not for designing a RAG from scratch (rag-design) or for evaluation only (rag-evaluate).
---

# rag-migrate

Move an existing RAG system to a decision-native evidence pipeline **without breaking what already works**. The baseline stays servable and restorable at every step.

```text
Before:  retrieve → rank → Top-K → LLM
After:   retrieve wide → decide → build evidence set → (sufficient? else expand) → LLM
```

Embeddings and rerankers are kept as candidate generators. What changes is who decides relevance, sufficiency, redundancy, conflict, freshness, and authority.

## Ground rules

- **Read before proposing.** No architecture recommendation until the real code path from query to answer has been traced.
- **Preserve the stack.** Implement in the project's existing language, framework, and deployment model. Do not add a sidecar service or a new language only because it is convenient for the agent.
- **No SDK calls from memory.** Before writing any provider or model call, look up the current public documentation and record the URL and date you used.
- **Replaceable decision engine.** The decision layer sits behind one interface. Hosted, local, open, proprietary, or cascaded engines must be swappable by configuration.
- **Rollback is a feature.** Every stage ships behind a flag that restores the baseline path in one change.
- **Public-safe artefacts.** Evaluation data from the user's system stays in the user's environment.

## Phase 0 — Inventory (read-only)

Produce a short inventory before touching code:

1. Entry points: where queries arrive, where answers leave.
2. Retrieval stack: index type, embedding model, sparse/keyword search, filters, reranker, Top-K value(s).
3. Context assembly: chunking rules, prompt template, token budget, citation handling.
4. Data lifecycle: ingestion, updates, deletions, versioning, document authority signals.
5. Observability: what is logged per request (query, candidates, scores, context, answer, latency, cost).
6. Constraints: latency SLO, cost ceiling, privacy boundaries, deployment targets.

Mark every item as *observed in code*, *stated by the user*, or *unknown*. Unknowns become questions or explicit assumptions.

## Phase 1 — Freeze the baseline

- Pin corpus version, index version, model versions, prompt, and Top-K.
- Add request-level tracing if missing: candidate ids, scores, delivered context ids, answer, latency, cost.
- Hand off to `rag-evaluate` to build a paired replay set on the frozen baseline. **Do not change retrieval behaviour before a baseline measurement exists.**

## Phase 2 — Widen retrieval (behind a flag)

- Raise the candidate pool (typically 20–200) while the delivered context stays at the current size.
- Combine dense, sparse, and metadata filters when the corpus supports them.
- Confirm the pool now contains the required evidence more often (candidate recall) — this is the ceiling for everything downstream.

## Phase 3 — Insert the decision layer

Define typed decisions, not prose. A minimal set:

| Decision | Output type | Purpose |
|---|---|---|
| `relevant` | yes / partial / no + probability | Filter candidates |
| `evidence_role` | supports / contradicts / context / none | Classify contribution |
| `stale_or_superseded` | current / superseded / unknown | Time and version |
| `authority` | ordinal level from corpus metadata | Resolve source hierarchy |

Implementation notes:

- Batch candidates per query; cache by (query hash, chunk id, engine version).
- Record every decision with probability and engine version for later audit.
- Start with the cheapest engine that passes offline gates; cascade to a stronger model only for low-confidence cases.

## Phase 4 — Build the evidence set

Replace the fixed Top-K cut with an explicit builder:

1. Drop `relevant = no`.
2. Deduplicate by **claim equivalence**, not text similarity alone; keep the most authoritative, most current representative.
3. Keep both sides of any contradiction and label the relation: contradiction, exception, supersession, or authority difference.
4. Check **sufficiency**. Zero items is a valid result. If insufficient, expand (reformulate, widen filters, follow references) up to a bounded number of rounds, then abstain or answer with stated gaps.
5. Pass the set with provenance (source id, version, date, role) to the reasoning step.

## Phase 5 — Progressive rollout

Each step needs its gate from `rag-evaluate` before the next:

1. Offline paired replay passes.
2. Shadow on live traffic — candidate runs, baseline serves.
3. Canary with hard guardrails (unsupported claims, p95 latency, error rate) and automatic rollback.
4. A/B with pre-declared primary and guardrail metrics.
5. Full rollout; keep the baseline path deployable for an agreed period.

## Deliverables

- `MIGRATION_PLAN.md`: inventory, assumptions, stage plan, flags, rollback steps, documentation sources used.
- Decision-engine interface plus one adapter.
- Evidence-set builder with unit tests for dedupe, contradiction, and sufficiency.
- Tracing additions.
- Gate results per stage, produced by `rag-evaluate`.

## Stop conditions

Stop and report instead of proceeding when:

- the baseline cannot be reproduced or traced;
- candidate recall does not improve after widening (the decision layer cannot recover what retrieval never found);
- a stage fails its gate twice with no identified cause;
- latency or cost leaves the approved envelope with no quality gain that justifies it.

Keeping the baseline is a valid outcome.
