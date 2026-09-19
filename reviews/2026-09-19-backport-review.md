# Backport review — 2026-09-19

Two outside drafts (v1.5: this repository plus a compiled-state lane; v2: a rewrite from an older base) were assessed for value before any merge. Neither was merged wholesale. A small set of ideas was ported; the drafts' site rewrites and v2's longer skills were not.

## Value assessment (before implementation)

| Reviewer | Route | Model (verified) |
|---|---|---|
| Claude | this session | Claude Opus 5 |
| GPT | `kiro-cli chat --v3`, read-only, neutral brief without the author's verdict | gpt-5.6-sol (`session.json` `modelId`) |

Both concluded: worth updating, not worth a full merge. Agreed to port scope-first retrieval, the confidence / sufficiency / validity split, deterministic verification, hot/control path with a degraded mode, A/B/C/D effect separation, and compiled state as a repo-level appendix only. Agreed to reject the site hero rewrite (promotes the least-proven idea), v2's site (drops OG/icon assets and QA), and v2's skills (245 → 612 lines).

GPT's correction adopted: the old "retrieve broadly" was already a bounded, ACL-filtered 20–200 candidate pool, so the scope change is a few lines, not a new slogan.

Author checks: the five public sources cited for compiled state were fetched and match the claims (vLLM APC long-document example; vLLM security `cache_salt` and CVE-2025-46570; llama.cpp `cache_prompt` and slot save; OpenJev shared-state path and its non-claims). The OpenCrab x JEV field guide is publicly reachable; its operator was not identified, so it is listed as a community guide.

## Implementation and review

Implementation: Grok (`sub run --profile implement`, grok-4.6). Review: `sub run --backend cursor --profile consult`, gpt-5.6-sol-high, read-only, numbered 11-item brief, two rounds in one session.

| # | Item | Round 1 | Round 2 |
|---|---|---|---|
| 1 | Scope-first wording vs original meaning | medium | partial — explicit scope could be widened with notice only |
| 2 | Confidence vs sufficiency vs schema | ok | resolved |
| 3 | Verify step order and failure loop | **high** — cited spans checked before citations exist; no re-verify after expansion | partial — verifier outage could fail open |
| 4 | Degraded mode and rollback | medium | resolved |
| 5 | A/B/C/D and gates | medium | partial — hard gates only offline/canary |
| 6 | Metric definitions | medium | partial — eviction denominator |
| 7 | Compiled-state claims | medium — L3 ID output implied; hosted APIs over-generalised | resolved |
| 8 | Source rows and `check.sh --sources` | low — unpinned doc URLs; repo regex broke on `/blob/` | partial — URLs still on `master` |
| 9 | Skill self-containment | ok | resolved |
| 10 | Invariants and brevity | low | resolved |
| 11 | Contradictions with untouched files | medium | deferred (site) |

Round 2 remainders were one-line wording fixes applied by the author: explicit scope is widened only on the user's say-so; every path, degraded ones included, passes deterministic verification and abstains if the verifier is unavailable; verification and source-recovery gates apply at all stages; hit/miss and eviction have separate denominators; GitHub document URLs are pinned to the recorded commits.

Deferred: the landing page still shows `Retrieve Wide → Decide → Evidence Set → Reason`; changing it needs a site update, narrow-viewport QA, and a manual deploy.
