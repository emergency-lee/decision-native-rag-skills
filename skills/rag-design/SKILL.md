---
name: rag-design
description: Design a new production RAG system as a decision-native evidence pipeline — corpus analysis, semantic units, hybrid broad retrieval, a pluggable decision engine, evidence-set construction with conflict and sufficiency handling, provenance, incremental updates, and built-in evaluation. Use when the user explicitly asks to design a RAG or knowledge-retrieval system where none exists yet. For an existing RAG use rag-migrate.
---

# rag-design

Design a retrieval-augmented system from the corpus and the use case, with explicit semantic decisions from day one instead of a fixed Top-K cut.

## Ground rules

- **Corpus first, stack second.** Understand documents, users, and questions before choosing a vector database or a model.
- **Fit the host project.** Use the language, framework, and infrastructure the team already runs.
- **Look up current documentation** before naming a provider API, SDK call, or model identifier. Record sources and dates.
- **Keep the decision engine pluggable** behind one interface.
- **Evaluation is part of the design**, not a later phase.

## Step 1 — Use case and corpus

Answer in writing:

- Who asks, what they ask, what a good answer looks like, and when abstaining is correct.
- Document types, volume, languages, update rate, deletions.
- **Authority**: which sources override which (official over informal, newer over older, specific over general).
- **Time**: validity periods, versions, supersession chains.
- Access control and privacy boundaries.

## Step 2 — Semantic units

Choose units that carry one claim or one self-contained passage, not fixed token windows. Keep structure (title path, section, table, list) and metadata (source id, version, effective date, authority level, access scope) on every unit.

## Step 3 — Broad retrieval

- Hybrid candidate generation: dense + sparse + metadata filters.
- Target a candidate pool large enough that required evidence is almost always present (commonly 20–200 units).
- Measure **candidate recall** separately; it is the ceiling for the whole system.

## Step 4 — Decision layer

Typed decisions per candidate, batched per query:

| Decision | Output |
|---|---|
| `relevant` | yes / partial / no + probability |
| `evidence_role` | supports / contradicts / context / none |
| `temporal_status` | current / superseded / unknown |
| `authority` | ordinal level |

Choose the engine by measured cost, latency, and accuracy on a labelled sample. Candidates include low-cost typed decision models, local open models scoring options without generating prose, rerankers, and general LLMs as a fallback. Cascade: cheap engine first, escalate only low-confidence cases.

## Step 5 — Evidence-set builder

1. Filter irrelevant units.
2. Deduplicate by claim equivalence; keep the most authoritative, most current representative.
3. Keep both sides of conflicts and label the relation: contradiction, exception, supersession, or authority.
4. Test sufficiency; expand within a bounded loop, or abstain and state the gap.
5. Hand the set to the reasoning model with provenance attached.

## Step 6 — Reasoning and answer

- Prompt the model to use only the evidence set and to cite unit ids.
- Surface unresolved conflicts to the user instead of silently choosing one side.
- Return answer, citations, and a gap or abstention note.

## Step 7 — Updates and operations

- Incremental ingestion with version tracking; invalidate decision caches when a unit or engine version changes.
- Per-request tracing: candidates, decisions, delivered set, answer, latency, cost.
- Budget alarms for decision-engine volume, since cheap judgements multiply quickly.

## Step 8 — Evaluation from day one

Create the labelled query set and metrics described in `rag-evaluate` alongside the first prototype. Compare against a plain Top-K baseline built on the same corpus so the decision layer has to earn its place.

## Deliverables

- `DESIGN.md`: use case, corpus analysis, authority and time model, architecture, interfaces, engine selection with evidence, operating envelope, open questions.
- A minimal end-to-end prototype in the host stack.
- An evaluation harness seeded with labelled queries.

## Stop conditions

- The corpus has no reliable way to express authority or time and the use case depends on them — fix the metadata first.
- The Top-K baseline already meets every target at lower cost — keep it simple.
