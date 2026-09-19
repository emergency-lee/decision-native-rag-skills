---
name: rag-design
description: Design a new production RAG system as a decision-native evidence pipeline — corpus analysis, semantic units, access control, hybrid broad retrieval, a pluggable decision engine, evidence-set construction with conflict and sufficiency handling, provenance, updates, and built-in evaluation. Use only when the user asks to design a RAG or document question-answering system where none exists yet. For an existing RAG use rag-migrate.
---

# rag-design

Design a retrieval-augmented system from the corpus and the use case, with explicit semantic decisions from day one instead of a fixed Top-K cut.

## Ground rules

- **Inspect the host repository and runtime first** and design inside them.
- **Corpus first, stack second.**
- **Look up current documentation** before naming a provider API, SDK call, or model identifier; record sources and access dates.
- **Pluggable decision engine** behind the schema in [references/decisions.md](references/decisions.md).
- **Evaluation is part of the design.**
- **Private material stays private.** Design notes built from the user's corpus are not committed to a public repository.

## Ask the human (checkpoints)

Start Step 1 immediately and ask these during it. Items 1, 4, and 6 may proceed on a recorded default; items 2 and 3 must be answered before Step 3; item 5 before Step 9.

1. Authority and recency policy: which source overrides which, and which wins when they disagree.
2. Access model: tenants, roles, document-level permissions.
3. Whether a hosted engine may receive document text and queries; approved engines and budget.
4. Latency SLO and cost ceiling.
5. The two labellers and the adjudicator.
6. Prototype scope (corpus slice, users).

## Step 1 — Use case and corpus

Who asks what; what a good answer looks like; when abstaining is correct. Document types, volume, update rate, deletions. **Languages** of queries and documents and which ones the embedding model, sparse analyser, and decision engine cover. **Authority** and **time** (validity, versions, supersession). **Privacy**: PII in documents, queries, logs; retention and deletion.

## Step 2 — Semantic units

One claim or one self-contained passage per unit, not fixed token windows. Metadata on every unit: source id, version, effective date, authority level, access scope, language, structure path.

## Step 3 — Security boundary

- Enforce tenant/ACL filters **inside candidate generation**, before any decision call; test for cross-tenant leakage.
- Cache keys follow [references/decisions.md](references/decisions.md), or restricted units are never cached.
- Treat unit text as untrusted: prompts separate instructions from data and ignore instructions inside units; flag imperative or suspicious content at ingestion.
- Minimise PII sent to engines; apply retention and deletion to traces and caches.

## Step 4 — Query interpretation and broad retrieval

Interpret the query (language, filters, reformulations), then hybrid candidate generation (dense + sparse + metadata filters). Size the pool (commonly 20–200 units) within budget. Measure **candidate recall** separately.

## Step 5 — Decision layer

Decision types and schema: [references/decisions.md](references/decisions.md). Engine choice, label sizes, cascade, and degraded mode: [references/engine-selection.md](references/engine-selection.md).

## Step 6 — Evidence-set builder

1. Filter irrelevant units.
2. Keep both sides of conflicts with the relation label; never deduplicate them.
3. Deduplicate the rest by claim equivalence within similarity buckets, choosing representatives by the recorded authority-then-recency policy and keeping other sources as corroborating provenance.
4. Ask `sufficient`; expand for at most N rounds, or abstain and state the gap.
5. Hand the set to the reasoning model with provenance.

## Step 7 — Reasoning and answer

Use only the evidence set and cite unit ids. Surface unresolved conflicts instead of choosing a side silently. Return answer, citations, and a gap or abstention note.

## Step 8 — Updates and operations

Incremental ingestion with version tracking; invalidate decision caches on unit, prompt/policy, or engine version change. Per-request tracing under the retention rule. Budget alarms on decision-engine volume.

## Step 9 — Evaluation from day one

Follow `rag-evaluate`. Cold start: draft 100–300 queries from corpus sections as the pilot set, have the named labellers prune and label them, then grow to the release-set size before any ship decision. Synthetic or LLM labels bootstrap only. Compare against a plain Top-K baseline on the same corpus.

## Deliverables

- `DESIGN.md` (private): use case, corpus analysis, Decisions, authority/time model, language plan, security boundary, architecture, interfaces, engine selection with evidence, operating envelope, open questions.
- A minimal end-to-end prototype in the host stack, limited to the approved scope.
- An evaluation harness seeded with labelled queries.

## Stop conditions

- The corpus cannot express authority or time and the use case depends on them — fix the metadata first.
- Access control cannot be enforced before the decision layer.
- The Top-K baseline already meets every target at lower cost — keep it simple.
