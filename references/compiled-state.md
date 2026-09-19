# Compiled Knowledge State

Compiled Knowledge State is a provider-neutral name for a reusable computational representation of stable knowledge — a transformer KV cache, persistent prefix/prefill state, reusable hidden states, a model-native recurrent state, learned memory tokens, or a model-independent semantic summary. It is an optional accelerator, not a knowledge store. Of these, only prefix/KV reuse (L1) is established in the cited sources.

```text
stable source knowledge
        ↓  expensive compile / prefill
reusable computational state
        ↓  cheap query-time activation or decision
semantic-unit IDs          ← L3 only, experimental
        ↓
authoritative source store
        ↓
exact passages, citations, and answer
```

L1 reuses computation for a shared prefix and still recovers evidence from the source store. The diagram's "semantic-unit IDs" output is not a claim that state returns evidence IDs today.

## Maturity (L0–L3)

| Level | Meaning | Status |
|---|---|---|
| L0 | Reread source text at query time | Default |
| L1 | Prefix/KV reuse of a shared prefix | Available today in some runtimes |
| L2 | Segmented compiled-state activation | Implementation-dependent |
| L3 | Direct state-addressed evidence selection (query → unit ids) | Experimental; not a default |

Prefix or prompt reuse is **computational reuse**. Some inference systems reuse the work for an identical prompt prefix (vLLM Automatic Prefix Caching documents repeated queries over the same long document; llama.cpp's server documents common-prefix KV reuse and slot prompt-cache save/restore). That does not by itself provide random access to a document or return a semantic evidence identifier. Do not treat L1 as L3.

OpenJev/SemIf documents a shared mode in which identical state is prefetched once and multiple criteria branch from it. Its results distinguish that shared-state path from reproducing Jev's architecture, training, benchmark, or advertised economics.

Adopt L3 only after an end-to-end comparison proves source recovery, answer quality, security, latency, memory, and invalidation.

## Hosted APIs

Hosted prompt or context caching gives L1-style reuse. Controls vary by provider (some expose cache breakpoints, keys, or time-to-live); do not assume state export, evidence IDs, per-segment invalidation, or lifecycle control unless the provider documents it. The full compiled-state lane is therefore mostly for self-hosted runtimes.

## Patterns

**Decision-native RAG (default).** Query → scoped retrieval → typed decisions → evidence set → verify → reason.

**Compiled-state RAG (optional).** Stable corpus → compile once → query activates or decides against state → unit IDs → recover source spans → verify → reason.

**Hybrid.** Search index, compiled state, and claim graph can all feed the same evidence-set builder. Retrieval remains the fallback. Compilation is a lane, not a reason to discard the source index.

## When to consider it

Inspect corpus size and stability, update and deletion frequency, query frequency and repeated-prefix rate, context capacity, RAM/VRAM and eviction, whether the runtime actually supports prefix caching, persistent prefill, state branching, or state export, citation requirements, and ACL/salt/timing risk.

| Workload | Starting point |
|---|---|
| Small, stable, frequently queried | Whole-corpus or few-segment feasibility test |
| Medium, stable, frequently queried | Segmented state plus routing and source recovery |
| Large or highly concurrent | Broad retrieval plus selected-segment activation |
| Frequently changing or rarely queried | Ordinary retrieval; compile only proven hot prefixes |
| Exact citation mandatory but state cannot return stable IDs | State for acceleration only; retrieve text by durable IDs |

Record why the path was selected, rejected, or limited to a benchmark lane.

## Not the source of truth

KV caches, hidden states, latent memories, and compiled summaries must not be the only copy of a fact.

> **Decide from the compiled state; cite from the source of truth.**

At compile time, keep a manifest mapping state fragments to durable units: `state_id`, `state_version`, model/tokenizer revision, and per unit `unit_id`, `source_id`, `source_version`, locator, `effective_from`, `span_hash`. The query path must resolve returned IDs against the source store before citation. If an ID cannot be resolved to a current authorised span, abstain, fall back to retrieval, or mark the gap. Do not invent a passage from latent state.

## Invalidation

```text
document diff → changed units → embeddings / sparse index
  → claim relations → affected compiled-state segments
  → cached answer or evidence-set artefacts
```

Invalidate on source content, version, effective date, or deletion; unit segmentation or span mapping; authority, ACL, retention, or cache-salt policy; model, tokenizer, prompt, policy, or engine revision; corruption, eviction, or failed source recovery. Prefer segment-level invalidation. Keep the prior state until the replacement passes source-recovery and stale-state tests. Activate atomically.

## Security

Compiled state can leak information even when no answer is returned. In a shared backend, cache hits can change time-to-first-token and expose whether another principal used a guessed prefix. vLLM documents this prefix-cache timing side-channel and an optional cache-salt mechanism.

1. Apply tenant and ACL filtering before compilation, activation, or decision calls.
2. Never share a state across principals unless the sharing boundary is explicitly authorised.
3. Include the access scope or an equivalent secret salt in the state/cache identity.
4. Use unpredictable per-user or per-tenant salts where isolation requires it; a visible user name is not a secret.
5. Treat state files, manifests, slot checkpoints, traces, and timing telemetry as potentially sensitive.
6. Test cache-hit timing, cross-tenant IDs, stale ACLs, and state-file restoration as security cases.
7. Compilation does not make source-unit text trusted instructions.

Salting reduces reuse. Measure the privacy boundary and the performance gain together.

## Evaluation

Every experiment has two paths:

```text
cold: documents → parse → tokenize → prefill / compile → query
warm: existing compatible state → query
```

Report, separately from ordinary RAG metrics: compile/prefill time and cold-start latency; warm-query latency and TTFT; cache hit, miss, eviction; state size, RAM/VRAM, concurrency; source-recovery accuracy and provenance completeness; stale-state incidents, invalidation latency, rebuild time; total cost over a representative workload, not warm latency alone.

For compile cost C, baseline per-query cost R, and warm cost K:

```text
N = C / (R - K), when R > K
```

This is only an amortisation estimate. Include cache misses, memory, invalidation, rebuilds, security controls, and source recovery in the real decision. A cache hit is a workload condition, not a quality result.

## Adoption

> **Detect capability → benchmark cold and warm paths → verify provenance and isolation → adopt only when the target workload wins.**

The safe default remains decision-native retrieval. Enable a compiled-state lane only for measured, stable, and authorised knowledge.
