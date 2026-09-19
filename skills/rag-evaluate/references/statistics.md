# Analysis, judge calibration, and live-stage sampling

Open this when writing `EVAL_PLAN.md` or analysing results.

Numbers marked *starting value* are common conventions, not derived requirements. Propose them, then let the owner tune them per project and record the choice.

## Offline analysis

- Per-query paired differences (candidate − baseline).
- 95% percentile bootstrap interval, ≥2000 resamples (*starting value*). Resample by cluster when queries share a user or session.
- Only the pre-declared primary metric and guardrails decide. Everything else is diagnostic. If many metrics or strata are tested, apply Holm correction or label them exploratory.
- Report a stratum's interval only if it has ≥30 queries (*starting value*).
- Queries where either arm abstains are reported separately, not dropped.
- "Improve" / "fall" in a gate means by at least the declared margin with the 95% interval excluding zero. Default margin for redundancy and unresolved contradictions: 20% relative (*starting value*).

## Pilot versus release set

- Pilot: 50–200 labelled queries (*starting value*). Verdict can only be *iterate* or *keep the baseline*.
- Release set: sized by a power calculation on the primary metric (state baseline rate and minimum detectable effect). If no estimate exists, ≥300 queries (*starting value*). Only the release set can produce *ship*.

## Judge calibration

- Two human labellers on ≥50 items (*starting value*); report their agreement.
- The judge is blind to which arm produced the output.
- Report the judge's confusion matrix and per-class errors against the human labels, especially on unsafe classes.
- The judge enters a gate only if its agreement with humans meets a pre-declared floor. Starting value: Cohen's κ ≥ 0.6, the lower bound of "substantial" agreement in Landis & Koch (1977), *Biometrics* 33(1):159–174. That scale is a convention, not a validity test.

## Canary

- Declare a minimum window and a minimum number of judged answers before any guardrail verdict — for example ≥200 (*starting value*).
- Guardrails are absolute rates over that window, with automatic rollback on breach.

## A/B

- Record baseline rate, minimum detectable effect, alpha, and power; compute the sample size.
- Check sample-ratio mismatch before reading results.
- Use a fixed horizon with no peeking, or a sequential method declared in advance.
