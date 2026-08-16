---
name: trust-your-instruments
description: >
  Use when a check, script, aggregator, gate or analysis tool reports a result —
  especially a negative result — and before acting on it. Use when a metric reads
  as a healthy constant, when a guard has never fired, when a CI poller says
  nothing is green, when a knob appears to do nothing, or when writing any script
  that answers a question about an input it located itself.
---

# Trust Your Instruments

*The examples throughout are separate recorded runs against the `lizTheDeveloper/multiverse_mages` build, measured August 2026 — not one incident retold four ways.*

A check that answers a question about the wrong input is worse than no check, because it answers confidently and nothing throws. This skill is orthogonal to the three-phase simulation arc — `ground-a-simulation`, `search-dont-argue`, `audit-a-simulation` — and runs alongside all three rather than being a fourth phase in it.

## When a check reports the negative case, confirm the check works

A check that says "no" gets trusted the moment it says it — "no bugs found", "nothing green", "never fired", "not started" all read as reassurance, and reassurance doesn't invite a second look. But the negative case is exactly where a broken checker and a correct checker are indistinguishable: both report nothing wrong, and neither throws. A checker that has quietly stopped looking at the right thing produces the same silence as a checker that looked and found nothing.

So the negative case is the one result that most needs the checker itself checked, and — because it doesn't feel like it needs anything — the one that least often gets it. Before acting on a negative result, confirm the check is looking at the input you think it is, and that it is capable of reporting the positive case at all. The rest of this skill is how.

## Positive controls

A checker that has only ever been observed rejecting has not been observed working. Rejection is not evidence of rigor by itself — it is equally consistent with a checker that is broken in a way that makes everything fail, or one that quietly never runs the comparison at all.

Give every checker an input it must accept, and run that input alongside the real one every time the checker runs. If the positive control fails, the checker is wrong, not the tree — say so and stop, before trusting anything it reported about the input you actually care about. A checker that reports zero failures and has never demonstrably passed anything is not a green result; it's an unverified one wearing a green result's clothes.

## The third exit

A checker with two exit codes has to fold "I could not tell" into one of them, and it always ends up in the same one: nonzero. A checker that is broken and a checker that ran cleanly and found the condition unmet produce identical exit codes, and every downstream reader learns "nonzero means shut" and stops asking which one actually happened. Folding "broken" into "no" is the default failure, not a rare mistake — it's what two exit codes forces.

Give a checker three exits instead: `0` the condition holds (open), `42` the condition does not hold (shut), `1` the probe could not answer (broken). A CI poller with only two exits cannot distinguish "the run failed" from "I couldn't reach the API to find out" — a caller has to guess, and guesses become permanent once nobody remembers there was one. See `references/probe-template.sh` for the skeleton, modeled on a working three-exit gate: `0` open, `42` shut, `1` broken probe.

## Locate input by name, never by shape

A script that finds its input by globbing a directory, by matching a file's shape, or by taking whatever `readdir` hands back first is answering a question about whichever file matched — not about the one anyone meant. Five instances of this shape turned up in one night, none of which threw, all of which reported confidently:

- An aggregator that globbed a directory folded **any** run's output into its report, not *this* run's — a second invocation ate the first invocation's records, taken at a different `--ticks`. The archive was well-formed, every number in it plausible, and the only symptom was a denominator that did not match the flag.
- An aggregator that located its input by **shape** rather than by name found the wrong input outright: the run's records were committed as CSV, the analyser read `.runs.ndjson`, and a before/after comparison silently compared the new run against itself.
- `awk '{print $2}'` on `gh pr checks` output. The columns are tab-separated and the first one contains spaces, so `Verify (pinned Node)` splits into three fields and `$2` is `(pinned`. A merge poller ran ten minutes reporting nothing green while both checks were green.
- jq's `//` operator on an empty string. A running job's `conclusion` field is `""`, not `null`, and `//` only falls through on `null` and `false` — not on an empty string. A watcher printed `not-started` for twenty consecutive polls while the run was already in progress.
- A CI gate that read the newest run instead of the run for `origin/main`. "Main is green" turned out to be a statement about whichever commit happened to be newest, not about main.

The fix is the same in every case: locate input by an explicit, named identifier — a ref, a run id, a flag value — never by glob, never by readdir order, never by "the file that looks like the right shape". See `references/known-false-checkers.md` for the catalogue, and append to it when a new instance turns up.

## A guard that cannot fire

The most dangerous broken guard is the one that looks right. `assertRepresentable` sat in the most-reviewed file in its codebase, looking correct for the project's entire history, passing against roughly 3,900 green tests. It was a bounds check meant to catch non-representable values — and every comparison with NaN is false, so a NaN sails through a bounds check without ever tripping it. The one value the guard existed to catch was structurally incapable of triggering it.

Nothing found this — not review, not the suite, not months of production use. It was found by someone asking whether the guard actually worked, not by a test going red. That is the tell: a guard that has never fired is not evidence that nothing has gone wrong. It is an untested code path wearing a green suite as camouflage. The remedy is a property test, not a unit test with more cases — "for all non-representable inputs, including NaN, this throws" — see `ground-a-simulation`, under **Property tests on the arithmetic**.

## A metric that cannot move

An axis that cannot move produces a one-cell archive that looks exactly like a finding: every run lands in the same bucket, the report renders cleanly, and nothing in the output signals that the metric was structurally incapable of reading anything else. Before pointing a human or an optimiser at a metric, prove the metric can move at all — an optimiser aimed at a metric that cannot move runs forever reporting progress against a number that was never going to change.

16 of 28 registered metrics were quarantined as structurally incapable of moving. Most of those had been reading as healthy constants, not as obviously broken — which is what makes this the output-side twin of the next section: a value that never moves and a knob that changes nothing are the same failure, once on what a check produces and once on what it consumes.

## Prove the knob moves the system

This is the input-side dual of the section above: instead of asking whether a metric can move, ask whether a tuning constant does anything at all. Amplify every authored magnitude by ×100, re-run, and diff against the unmodified run. Byte-identical output means the value is wired into the config and inert in the system — read, maybe even logged, but never consulted by anything that changes the outcome.

Amplifying a set of authored constants ×100 and diffing against the unmodified run, on lesson and research counts:

| primitive | lessons | research | verdict |
|---|--:|--:|---|
| control | 1867 | 4571 | — |
| research-rate ×100 | 1779 | 4541 | moves |
| teach-rate ×100 | 1288 | 4564 | moves — −31% |
| scribe-rate ×100 | 1414 | 4407 | moves |
| lifespan ×100 | 1867 | 4571 | **byte-identical** |
| fertility ×100 | 1867 | 4571 | **byte-identical** |

`lessons` and `research` are just two run outputs the amplified run was checked against — nothing more meaningful than a pair of counters — and the whole diagnostic rests on `lifespan` and `fertility`'s rows landing on those same two counters unchanged: identical output under a ×100 amplification is the finding, not an incidental detail of it.

Three of the five rates were genuinely live — `teach-rate` the strongest of them, moving lessons by nearly a third, and previously on record as the constant measured most confidently to be doing nothing. `lifespan` and `fertility` were wired and inert: present in the config, read somewhere in the code, connected to nothing that changed the run.

The detail that earns this a section rather than a bullet: a static consumption check — "is this value read anywhere?" — named a consumer for both `lifespan` and `fertility`, and passed. "Is this value read?" and "does this value change anything?" are different questions. They come apart silently, and the gate that looks like it covers you is exactly the one that doesn't. The engineer who found it summarised it as: "no gate I used could have seen it."

This is `search-dont-argue`'s **Both degenerate ends as controls**, applied to wiring instead of tuning. Ablation and amplification are one instrument pointed two directions: one asks whether removing a value changes anything, the other asks whether maxing it out does — and a constant that survives both untouched was never actually part of the system.
