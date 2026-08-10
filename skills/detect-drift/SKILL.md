---
name: detect-drift
description: >
  Use when checking whether documentation, tests, or specs still match the code —
  or when setting up scheduled automation to check it repeatedly. Covers the three
  drifts (documentation, test, spec/implementation), how to detect each, and why
  they are the best candidates for unattended routines. Use when a green test suite
  is not reassuring, when docs are suspected stale, or when asked "what should I
  automate?"
---

# Detect Drift

Three things rot silently while the code moves: **the documentation, the tests, and the spec.** None of them break a build. Nobody is reminded to check. By the time drift is noticed it is usually via a regression that "should have been caught".

This makes drift the single best candidate for scheduled automation. It is unattended, repeatable, tied to a clear outcome, and — importantly — **it needs no deploy authority**. A drift routine reads and files issues. It changes nothing. That puts it comfortably on the safe side of the automation line.

## The three drifts

### Documentation drift

The docs describe a system that no longer exists. This is worse than having no docs, because stale docs are trusted.

**Detect:** re-derive the documentation from the current code and diff it against what is committed. Flag any section that references an endpoint, table, config key, environment variable or symbol that no longer exists — those are mechanically checkable and are most of the value.

**Report as:** a list of specific stale statements, each with the line that contradicts it. Not "the docs are out of date".

### Test drift

The suite is green and no longer tests anything that matters. Common shapes:

- Assertions that cannot fail (`assert response is not None`)
- Endpoints or branches added since the last review with no coverage
- Tests that would still pass if the feature were deleted
- Mocks that have drifted from the thing they mock, so the test verifies the mock

**Detect:** flag tests with no meaningful assertion, and code paths added since the last run with no corresponding test. The strongest version is **mutation-style**: deliberately break a behaviour and confirm the suite actually goes red. A test that does not fail when the behaviour breaks is not a test.

This matters far more when the tests and the code were written by the same agent in the same pass — the failure mode is a suite that is perfectly consistent with the implementation and indifferent to the requirement.

### Spec / implementation drift

The spec says one thing, the code does another. Neither looks wrong in isolation, which is exactly why this survives review.

**Detect:** walk each requirement or acceptance criterion and check there is both an implementation and a test. Produce three lists:

1. Criteria with **no implementation** — silently dropped
2. Criteria with an implementation but **no test** — where the next regression comes from
3. Behaviour in the code with **no corresponding criterion** — scope that arrived without a decision

The third list is the one people find most uncomfortable and most useful.

## Running it as a routine

Schedule these; do not rely on remembering.

- **Weekly** is right for documentation and spec drift. Daily is noise.
- **Per release** for test drift, as part of the pre-promotion checks.
- Have it **open issues**, deduplicated, rather than post a report nobody reads. See the `wire-telemetry` skill for the errors-to-issues pattern — this is the same mechanism.
- Give the routine repository and issue-tracker access and **nothing else**. It reads and files; it does not fix, and it does not deploy.

Resist the temptation to have it auto-fix what it finds. A drift routine that also edits produces a stream of unreviewed changes, which is the problem it exists to detect.

## Reporting

Every finding needs to be actionable on its own:

- The specific claim that is now false
- The evidence — file and line, or the test that passes when it should not
- What changed underneath it, if determinable

**Report an empty result plainly.** "No drift found in X, Y, Z" is a real outcome and should be stated, not padded. If a check could not run, say which and why — a skipped check silently reported as clean is the worst possible output.
