# Adversarial review — 2026-09-19

Author of the reviewed files: Claude Opus 5. Reviewers ran in separate sessions, read-only, with the same numbered brief.

| Reviewer | Route | Model (verified) |
|---|---|---|
| Fable | fresh Claude agent, no author context | Claude Fable 5.1 |
| Grok | `sub run --profile consult` | grok-4.6 (envelope `effective.model`) |
| GPT | `kiro-cli chat --v3` | gpt-5.6-sol (`session.json` `modelId`) |

## Round 1 — 11 items

| # | Item | Fable | Grok | GPT |
|---|---|---|---|---|
| 1 | Spec validity | ok | ok | ok |
| 2 | Triggering | minor | major | minor |
| 3 | rag-migrate production gaps (ACL, cache, cost, logs, rollback) | major | major | major |
| 4 | rag-migrate technical claims | major | major | major |
| 5 | Evaluation statistics | major | major | major |
| 6 | Metric operability | major | major | major |
| 7 | rag-design security / cold start | major | major | major |
| 8 | Cross-file consistency | minor | major | major |
| 9 | Public claims | major | minor | minor |
| 10 | Agent executability | major | major | major |
| 11 | Human approval before live actions | **critical** | **critical** | **critical** |

Fixed in `22e438e`. Author checks before fixing: TypeSafe post shows "Sep 15, 2026" (site said 2026-09-14 → corrected); the three open implementations' READMEs support the site's statements (Qwen / Gemma, shared prefill, one-pass option scoring, Jev HTTP API), so the statements stayed and the badge changed from OBSERVED to REPORTED.

Rejected:
- Broadening rag-migrate's trigger to "Top-K gives redundant context" (Fable) — conflicts with the other two reviewers' request to narrow triggers.

Applied later at the owner's request: the domain-specific category in the site's exclusion list was generalised (Fable, both rounds).

## Round 2 — verification of claimed fixes + new defects

| Claim | Fable | Grok | GPT |
|---|---|---|---|
| F1 human approval | FIXED | PARTIAL | PARTIAL |
| F2 ACL / cache / injection | FIXED | PARTIAL | PARTIAL |
| F3 decisions + schema | FIXED | FIXED | FIXED |
| F4 dedupe / stop / cascade | FIXED | FIXED | FIXED |
| F5 statistics | FIXED | FIXED | FIXED |
| F6 metrics | FIXED | PARTIAL | FIXED |
| F7 rag-design | FIXED | FIXED | FIXED |
| F8 README | FIXED | PARTIAL | PARTIAL |
| F9 public claims | FIXED | PARTIAL | FIXED |
| F10 triggers / ask-the-human | FIXED | FIXED | FIXED |

New defects raised and fixed in the round-2 commit:
- "Ask the human (stop until answered)" blocked offline work (all three) → checkpoints with per-item timing.
- Schema had no place for `sufficient` missing aspects / `authority` level (Fable, GPT) → `detail` field.
- Pilot set could not produce a release verdict (Fable, Grok) → pilot = iterate/keep only; ship needs a powered release set or ≥300 queries.
- Offline "successful task" ignored answer correctness (GPT) → judged correct and complete.
- Rollback rehearsal timing, first-pass vs expanded candidate recall, two labellers, units **and** claims, derived decision labels, `partial` in precision, `n_undefined`, README metric names, rag-design cache key tuple, site evaluate card and "Observed facts" wording, protocol "probabilities" wording, historical production data to a new provider during offline replay.

Review limit reached (two rounds). Remaining risk: trigger behaviour is untested in real use.
