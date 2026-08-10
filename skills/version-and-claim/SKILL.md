---
name: version-and-claim
description: >
  Use when cutting a release, choosing a version number, writing release notes, or
  when the user cannot tell whether their project is getting better or worse.
  Covers semantic versioning and what it is actually for, cohorts as release
  boundaries, falsifiable release claims, and finding a regression by bisecting to
  the version where it last worked.
---

# Version and Claim

This skill exists to prevent one specific failure: **building a great deal, very fast, and taking one step forward and two steps back without noticing.** That is what high-output development looks like from outside when there is no way to tell whether the thing is improving.

Three pieces of machinery prevent it: a version number, a release boundary, and a claim that can be wrong.

## Semver, and what it is actually for

`MAJOR.MINOR.PATCH` is not bookkeeping. It is **a promise about what breaks**:

- **MAJOR** — existing usage breaks. Someone must do something.
- **MINOR** — new capability, nothing existing breaks.
- **PATCH** — a fix, no new surface.

The underrated value is that it makes "we regressed" a checkable statement. Without versions, a regression is a feeling. With them, it is "worked in 2.3.1, broken in 2.4.0" — which is a bisect, not an argument.

When the user asks "what version should this be?", the question to ask back is: **does anything that worked before stop working?** That answers it.

### Tags are not enough on their own

A tag records a point; it does not describe the line. If 150 commits ship past the last tag, that tag now under-describes what is live and is not a safe rollback marker. Either tag every release or do not trust tags as a rollback story — and say which is true rather than assuming.

## Cohorts are your release boundary

Ship on a boundary that means something to the people using the software.

If the user thinks they have no cohorts, they do. A SaaS or a game has **people who onboarded in a given window**, and those people experience the software as a version. That window is the natural moment to ship a visible change, and the natural vocabulary for saying who got what.

This gives you something arbitrary date-based releases do not: a way to say "everyone who joined after March gets this" and have it mean something to a human.

A version scheme can encode the boundary. One live example: MINOR is cohort-tied and **even means stable, odd means unstable**, so the version number itself says whether you are looking at a tested line; PATCH encodes week-and-day within the cohort. Encoding is optional — having a boundary is not.

## Claims: the part people skip

**Every release should assert something that could turn out to be false.**

| Not a claim | A claim |
|---|---|
| "Improved performance" | "Checkout completes under 2s at p95" |
| "Better onboarding" | "New users reach first save without support contact" |
| "Fixed the sync bug" | "Two devices editing the same note converge within 5s" |

The test is simple: **what measurement would prove this wrong?** If nothing could, it is activity, not a claim — and it cannot detect a regression, which is the entire point.

Then the second, harder question: **do you currently collect that measurement?** If not, say so plainly rather than inventing a metric that cannot be checked. An unverifiable claim is worse than none, because it feels like rigour.

Agents will generate the activity-shaped kind forever if allowed. It is the register that always sounds like progress. When drafting release notes, convert each line into a falsifiable claim or drop it.

## Finding a regression

When something worked and no longer does, do **not** start by reading code and guessing.

1. Establish the last version where it worked
2. Bisect between that and now
3. *Then* look at what changed

This ordering matters because the intuitive cause is frequently wrong, and reading code confirms whatever you already suspect. Establish which commit changed the behaviour first; explain second.

## Cutting a release

Produce, in order:

1. The version number, with a one-line justification tied to what breaks
2. Release notes as **claims**, each one falsifiable
3. For each claim, the measurement that would disprove it — and whether it is actually collected
4. The rollback marker: the exact version to return to, verified as really being what is live
5. The human test plan — see the `verify-release` skill

Then stop. Promotion to production is a human decision.
