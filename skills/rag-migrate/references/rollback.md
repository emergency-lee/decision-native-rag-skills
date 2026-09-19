# Rollback runbook and live-stage approval

Open this before Phase 5.

## Approval record (one per live stage)

Stage · environment · traffic share · window · guardrails and thresholds · data boundary (which provider sees which data) · expected extra cost (shadow roughly doubles decision cost) · rollback owner · approver and date.

## Runbook

Write it before shadow. Rehearse it in staging before shadow and once more during shadow. Do not claim one-change rollback until the rehearsal passes.

List every change and how it is reverted:

- serving flag (baseline path);
- indexes added or rebuilt — keep the baseline index servable;
- schema changes — backward compatible, or dual-write until rollback window ends;
- prompt templates and query-interpretation changes;
- ingestion changes;
- caches — separate namespace per pipeline version, so rollback never reads candidate entries;
- external engine dependencies and credentials.

Record the rollback trigger (which guardrail, which threshold), who executes it, and how success is verified.
