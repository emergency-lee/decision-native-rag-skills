---
name: rag-design
description: Design a new production RAG system as a decision-native evidence pipeline — corpus analysis, semantic units, access control, hybrid broad retrieval, a pluggable decision engine, evidence-set construction with conflict and sufficiency handling, provenance, updates, and built-in evaluation. Use only when the user asks to design a RAG or document question-answering system where none exists yet. For an existing RAG use rag-migrate.
---

# rag-design

Design a retrieval-augmented system from the corpus and the use case, with explicit semantic decisions from day one instead of a fixed Top-K cut.

## Ground rules

- **Inspect the host repository and runtime first** — language, framework, infrastructure, existing data stores — and design inside them.
- **Corpus first, stack second.** Understand documents, users, and questions before choosing a vector database or a model.
- **Look up current documentation** before naming a provider API, SDK call, or model identifier. Record sources and access dates.
- **Keep the decision engine pluggable** behind the shared schema in `references/architecture-principles.md`.
- **Evaluation is part of the design**, not a later phase.
- **Private material stays private.** Design notes built from the user's corpus are not committed to a public repository.

## Ask the human (checkpoints)

Start Step 1 immediately and ask these during it. Items 1, 4, and 6 may proceed on a recorded default; items 2 and 3 must be answered before Step 3; item 5 before Step 9.

1. Authority and recency policy: which source overrides which, and which wins when they disagree.
2. Access model: tenants, roles, document-level permissions.
3. Whether a hosted engine may receive document text and queries; approved engines and budget.
4. Latency SLO and cost ceiling.
5. Who the two labellers and the adjudicator are.
6. Scope of the prototype (which corpus slice, which users).

## Step 1 — Use case and corpus

Answer in writing:

- Who asks, what they ask, what a good answer looks like, and when abstaining is correct.
- Document types, volume, update rate, deletions.
- **Languages**: languages of queries and documents, whether they can differ, and which languages the embedding model, sparse analyser, and decision engine actually cover.
- **Authority** and **time**: validity periods, versions, supersession chains.
- Privacy: PII present in documents, queries, and logs; retention and deletion requirements.

## Step 2 — Semantic units

Units carry one claim or one self-contained passage, not fixed token windows. Keep structure (title path, section, table, list) and metadata on every unit: source id, version, effective date, authority level, access scope, language.

## Step 3 — Security boundary

- Enforce tenant/ACL filters **inside candidate generation**, before any decision call. Test for cross-tenant leakage.
- Cache key: principal access scope, query hash, unit id and version, engine version, and prompt/policy version — or restricted units are never cached.
- Treat all unit text as untrusted: decision and reasoning prompts keep instructions and data separate and ignore instructions inside units; flag imperative or suspicious content at ingestion and log hits.
- Minimise PII sent to engines; apply the retention and deletion rule to traces and caches.

## Step 4 — Query interpretation and broad retrieval

- Interpret the query: language, filters (time, source, scope), and reformulations for sparse and dense search.
- Hybrid candidate generation: dense + sparse + metadata filters.
- Target a pool large enough that required evidence is almost always present (commonly 20–200 units), within the latency and cost budget.
- Measure **candidate recall** separately; it is the ceiling for the system apart from bounded expansion.

## Step 5 — Decision layer

Typed decisions (shared schema: `label`, `score`, `score_kind`, `calibrated`, `detail`, `abstain_reason`, `engine_version`; `authority` level and `sufficient` missing aspects go in `detail`):

| Decision | Scope | Labels |
|---|---|---|
| `relevant` | per unit | yes / partial / no |
| `evidence_role` | per unit | supports / contradicts / context / none |
| `temporal_status` | per unit | current / superseded / unknown |
| `authority` | per unit | ordinal level |
| `claim_equivalent` | per pair | yes / no |
| `sufficient` | per evidence set | sufficient / insufficient + missing aspects |

**Engine selection**: labels are derived from the query labels (units, equivalence groups, conflicts) rather than collected separately; `claim_equivalent` pairs are sampled within similarity buckets. Use ~50 per decision type as a pilot and ≥200 per type (≥100 sets for `sufficient`) for the final choice. Measure accuracy, calibration (reliability plot or ECE), cost, p95 latency, language coverage, privacy/residency, licence, availability, and behaviour on adversarial units. Candidates include low-cost typed decision models, local open models that score options without generating prose, rerankers, and general LLMs as fallback. Cascade only with calibrated scores; choose the escalation threshold on the labelled sample. Define a degraded mode (plain Top-K) when the engine is unavailable.

## Step 6 — Evidence-set builder

1. Filter irrelevant units.
2. Keep both sides of conflicts and label the relation: contradiction, exception, supersession, or authority. These pairs are never deduplicated.
3. Deduplicate the rest by claim equivalence within similarity buckets, choosing representatives by the recorded authority-then-recency policy and keeping other sources as corroborating provenance.
4. Ask `sufficient`; expand for at most N rounds, or abstain and state the gap.
5. Hand the set to the reasoning model with provenance attached.

## Step 7 — Reasoning and answer

- Use only the evidence set; cite unit ids.
- Surface unresolved conflicts to the user instead of silently choosing a side.
- Return answer, citations, and a gap or abstention note.

## Step 8 — Updates and operations

- Incremental ingestion with version tracking; invalidate decision caches when a unit, prompt/policy, or engine version changes.
- Per-request tracing under the retention rule: candidates, decisions, delivered set, answer, latency, cost.
- Budget alarms on decision-engine volume.

## Step 9 — Evaluation from day one

Follow `rag-evaluate`. Cold start: draft 100–300 queries from corpus sections as the pilot set, have the named human prune and label them with the rubric, then grow to the release-set size defined in `rag-evaluate` before any ship decision. Synthetic or LLM labels bootstrap only and are never the sole release evidence. Compare against a plain Top-K baseline on the same corpus so the decision layer has to earn its place.

## Deliverables

- `DESIGN.md`: use case, corpus analysis, Decisions list, authority/time model, language plan, security boundary, architecture, interfaces, engine selection with evidence, operating envelope, open questions.
- A minimal end-to-end prototype in the host stack, limited to the approved scope.
- An evaluation harness seeded with labelled queries.

## Stop conditions

- The corpus cannot express authority or time and the use case depends on them — fix the metadata first.
- Access control cannot be enforced before the decision layer.
- The Top-K baseline already meets every target at lower cost — keep it simple.
