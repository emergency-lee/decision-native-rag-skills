# Decision-Native RAG Skills

Agent Skills for migrating, evaluating, and designing RAG systems around a **decision-native evidence pipeline** rather than fixed Top-K retrieval.

> Retrieve broadly. Decide explicitly. Build an evidence set. Resolve conflicts. Reason only over what matters.

This repository is intentionally **provider-agnostic**. Jev and open implementations such as OpenJev are important examples of low-cost semantic decision operators, but the skills do not require any one model, SDK, language, vector database, or orchestration framework.

## Why this exists

Classic production RAG usually compresses several different problems into a single ranking step:

1. find potentially relevant material,
2. decide what is actually relevant,
3. remove redundancy,
4. detect conflicting evidence,
5. decide whether the evidence set is sufficient,
6. choose the right authority/version,
7. assemble context for a reasoning model.

Embedding similarity and reranking are useful, but they are not identical to these decisions. A new class of fast typed decision models makes it practical to separate **candidate retrieval** from **semantic evidence selection**.

TypeSafe describes Jev as a System One model that maps unstructured state to typed probabilistic decisions rather than generated prose. Independent open-source projects have already reproduced parts of this interface pattern using open models and local inference. This repository treats that as an architectural signal, not as proof that any one implementation is universally superior.

## The three skills

### 1. `rag-migrate`
For an existing RAG system. The agent first inspects the real codebase, data flow, retrieval stack, access control, observability, and constraints. It then designs an incremental migration that preserves rollback and external behaviour while adding a decision layer, evidence-set construction, and contradiction handling. Offline replay is the last autonomous stage: shadow, canary, and A/B each require recorded human approval.

### 2. `rag-evaluate`
For baseline-versus-candidate comparison. It creates a task-specific evaluation plan from the current system and corpus, runs offline paired replay, and prepares shadow, canary, and A/B stages that run only with human approval. It measures retrieval, evidence quality, answer support, latency, cost, and user-facing outcomes.

### 3. `rag-design`
For a system with no existing RAG. It designs a production architecture from the corpus and use case, including source ingestion, semantic units, access control and prompt-injection boundaries, hybrid broad retrieval, a pluggable decision engine, evidence-set optimisation, conflict/temporal logic, provenance, updates, and evaluation.

## No bundled Python harness

These skills deliberately contain **no required `scripts/` directory and no Python-specific harness**.

The agent is instructed to:

- inspect the existing repository and runtime first,
- preserve the project's language and framework where reasonable,
- search current public documentation before choosing or changing provider APIs,
- generate the smallest fit-for-purpose code/evaluation harness inside the target project,
- avoid inventing stale SDK calls from memory,
- document assumptions and sources,
- make the decision-model adapter replaceable.

This means the same skill can work in Python, TypeScript, Java, Go, or mixed stacks without forcing a sidecar implementation simply because the skill was authored in one language.

## Architecture

```text
                         ┌──────────────────────┐
Query ──────────────────►│ Query interpretation │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ Broad retrieval      │
                         │ dense/sparse/filters │
                         └──────────┬───────────┘
                                    │ 20–200 candidates
                                    ▼
                         ┌──────────────────────┐
                         │ Semantic decisions   │
                         │ relevance/evidence   │
                         │ freshness/authority  │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ Evidence-set builder │
                         │ dedupe / diversify   │
                         │ conflict / coverage  │
                         └──────────┬───────────┘
                                    │
                              sufficient?
                              │         │
                             no         yes
                              │         │
                    retrieve/expand     ▼
                              │  ┌──────────────────────┐
                              └─►│ Reasoning/generation │
                                 └──────────┬───────────┘
                                            │
                                            ▼
                                 answer + provenance
```

The core idea is not "replace embeddings". Embeddings remain excellent candidate generators. The change is to stop asking a single similarity score or fixed Top-K cutoff to solve relevance, evidence sufficiency, redundancy, conflict, time, and authority at once.

## Performance thesis

This repository does **not** claim a universal benchmark result. Performance must be measured on the target system.

The skills instead propose a falsifiable hypothesis:

> At comparable answer quality and safety, broad retrieval followed by explicit semantic evidence decisions can improve evidence recall and reduce irrelevant/redundant context compared with a fixed Top-K pipeline, while keeping total latency and cost within an acceptable operating envelope.

### Default acceptance targets

These are starting gates, not universal promises. `skills/rag-evaluate/SKILL.md` holds the canonical table and metric definitions; thresholds are declared per project and approved by the system owner.

| Dimension | Default migration gate |
|---|---|
| Required-evidence recall | improve, or no regression when baseline is already high |
| Delivered-evidence precision | improve or remain within agreed tolerance |
| Redundant/claim-equivalent context | fall by the declared margin |
| Unresolved contradiction rate | fall by the declared margin |
| Unsupported answer claims | must not regress |
| Citation/provenance completeness | must not regress |
| p95 end-to-end latency | remain within product SLO or explicitly approved trade-off |
| Cost per successful task | improve or justify quality gain |
| User/task success | improve in live testing before full rollout |

A team should not ship a migration merely because an offline LLM judge prefers it.

## Evaluation model

`rag-evaluate` treats evaluation as four stages:

1. **Offline frozen replay** — same queries, same corpus version, paired baseline/candidate runs.
2. **Shadow** (human approval) — candidate executes on real traffic but baseline continues to serve users.
3. **Canary** (human approval) — small percentage receives the candidate under hard guardrails and rollback.
4. **A/B** (human approval) — sticky random assignment with pre-declared primary and guardrail metrics.

The skill extends conventional RAG measures such as context precision, context recall, and faithfulness with evidence-system metrics:

- required-evidence recall,
- evidence coverage,
- redundancy ratio,
- contradiction capture rate,
- contradiction resolution accuracy,
- temporal/authority correctness,
- unsupported-claim rate,
- provenance completeness,
- latency and cost distributions.

## Why Jev matters to this architecture

TypeSafe's public description of Jev is significant because it frames semantic judgement as a first-class software primitive: structured questions in, typed probabilistic decisions out, with no need to generate and parse prose. Their launch post reports that Jev is two orders of magnitude faster and more efficient than existing LLMs on System One tasks; this is a vendor claim and is not verified here.

Independent open-source work is also notable. Current public projects show that open models can implement one-pass or prefill-only option scoring, shared-state computation, and Jev-compatible APIs. The strongest public results remain early and workload-dependent; they do **not** establish full Jev parity or universal economics.

The architectural implication is still useful even if vendors/models change:

```text
Old default:   retrieve → rank → Top-K → LLM
New option:    retrieve wide → decide → build evidence set → LLM
```

The decision layer can be hosted, local, open, proprietary, task-specific, or cascaded.

## Public-data-only policy

This public repository was authored from public sources and generic examples only. It contains:

- no private benchmarks,
- no personal conversation history,
- no private medical or organisational material,
- no proprietary document corpus,
- no unpublished evaluation data.

See [`PUBLIC_DATA_POLICY.md`](PUBLIC_DATA_POLICY.md).

## Skill format

Each skill follows the open Agent Skills `SKILL.md` convention: YAML frontmatter with `name` and `description`, followed by Markdown instructions. Scripts are optional under the standard and are deliberately omitted here.

## Repository layout

```text
skills/
  rag-migrate/SKILL.md
  rag-evaluate/SKILL.md
  rag-design/SKILL.md
references/
  architecture-principles.md   shared decision schema
  evaluation-protocol.md
  public-sources.md
index.html, styles.css, app.js   landing page (https://jev-shift.vercel.app)
favicon.*, icon-*.png, og.png, site.webmanifest
vercel.json, DEPLOY.md, qa/
PUBLIC_DATA_POLICY.md
LICENSE
```

## Public sources

The source list is maintained in [`references/public-sources.md`](references/public-sources.md). Core references include:

- TypeSafe AI — Introducing System One Models and Jev: https://typesafe.ai/blog/introducing-system-one-models-and-jev
- TypeSafe AI — product/FAQ: https://typesafe.ai/
- TheoLeeCJ/openjev: https://github.com/TheoLeeCJ/openjev
- daseinlabs/open-jev: https://github.com/daseinlabs/open-jev
- ekzhang/openjev-sglang: https://github.com/ekzhang/openjev-sglang
- Microsoft GraphRAG: https://microsoft.github.io/graphrag/
- Ragas metrics: https://docs.ragas.io/
- Agent Skills specification: https://agentskills.io/specification

## License

MIT. See [`LICENSE`](LICENSE).
