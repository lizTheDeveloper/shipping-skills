---
name: audit-a-simulation
description: >
  Use when a running simulation, game or model is producing numbers you are not
  sure you can trust — a metric that never moves, a balance result that might be
  a bug wearing a design outcome's clothes, a strategy space that may have
  collapsed, a gate that stacks unrelated PRs. Also use when inheriting a system
  that already has baselines.
---

# Audit A Simulation

**Phase 3 of three.** The numbers exist and something is now standing on them. Grounding the system is `ground-a-simulation`; finding numbers nobody can defend is `search-dont-argue`. `trust-your-instruments` is orthogonal to the arc, runs across all three phases, and is where a metric that never moves, a guard that has never fired, or a knob that turns out to be inert actually get handled.

The characteristic failure here is not a crash. It is a plausible number.

## First: which foundations do you actually have?

The temptation on a system that already has numbers is to skip straight to the interesting question — is this particular metric real — and treat the boring one as settled. That's backwards, and it's expensive to discover backwards: any audit technique run on top of a missing foundation is measuring the gap with more precision, not measuring the system.

Before trusting anything this system reports, check which of five foundations it actually has: determinism, stream-split randomness, an identity baseline, pinned metric definitions, and a null to score everything else against. Not "has someone mentioned" each of these — verify each one exists and holds, the same things `ground-a-simulation` says to build before the first measurement. See that skill, under **What you can pin before you know any numbers**. For the metric-definition foundation specifically, "pinned" is not the same as "alive" — confirm a metric can move at all before trusting anything measured against it; see `trust-your-instruments`, under **A metric that cannot move**.

If any of the five is missing, the answer is not "proceed carefully, adjust for the gap." It is **stop, and retrofit the missing foundation before trusting anything measured on top of it.** This is not caution for its own sake — it follows directly from the retrofit test: a missing foundation invalidates every number taken without it, so refining the audit technique on top of that gap only produces a more confident wrong answer. Stating this as a verdict, not a patch, is what stops the rest of this document from being read as a workaround for a problem it cannot actually fix by being careful.

## The silent zero

The characteristic bug of a numeric system is not a crash. It is a legitimate-looking zero: nothing throws, nothing is corrupt, and the result reads as a balance outcome rather than as a defect. Two independent routes arrive at the same destination.

The first route runs through `NaN`:

```
a lookup misses
  -> undefined enters arithmetic
  -> NaN comes out
  -> it is written to an integer column
  -> the typed array coerces NaN to 0
  -> the mechanic contributes nothing, forever
```

The second route involves no `NaN` at all. Division that rounds toward negative infinity means a small per-tick increment can floor to exactly zero — and once it does, every subsequent tick floors the same increment to the same zero, so the quantity it was supposed to move never moves again. Call this the **Zeno stall**: the arithmetic is working perfectly at every single step, and the value is still pinned forever.

Same defect, two complaints. Whoever is looking at the intermediate value calls it NaN contamination. Whoever is looking only at the stored value calls it a quantity that fell to zero — a plausible design outcome, even a defensible one, wearing a bug's clothes. Neither description is wrong, and neither is complete by itself; a report that only names one of them sends the fix looking in the wrong place.

## Why the unit suite is structurally blind to it

A green unit suite is not evidence against the silent zero, and this is not for want of tests. It can be extensive, specific, and well-written, and still never see it, because **a unit test builds its own fixture, so its lookups always hit.** It constructs a record, interns an id, and hands both straight to the code under test — the registry the id gets looked up in is the same registry the test just populated a moment earlier. It cannot miss.

Production looks the same value up in an assembled registry built by an entirely different subsystem, where a key may simply not resolve and a caller may pass an empty array instead of the record the test always supplies. Every one of those unit tests can be correct and green while the assembled system computes zero right next to them.

The missing artifact is never *more* unit tests — a hundred more fixtures built the same way hit the same way, for the same reason. It is a test of a different category entirely: run the assembled system, not a fixture built to resemble it, and watch the boundaries where one subsystem's output becomes another's input. See `ground-a-simulation`, under **Prototype the subsystem to find the integration test** — that section is the positive framing of this same boundary: prototyping is how you learn which boundaries the assembled-system test needs to watch, before finding out the hard way that the unit suite never watched them at all.

## Absence claims require execution

"There is no X," read off the code, is not a finding. It is a guess wearing a finding's clothes, and nothing about the sentence distinguishes the two cases until someone runs it.

Multiverse Mages had exactly this happen, stated with real confidence: "unmasking four actions during engagement moves every balance baseline" was asserted from reading the code, and it was false. Instrumenting the mask and running strategies against it showed the branch in question is evaluated **zero** times — not rarely, not in some edge case, zero — because raids resolve entirely inside one world step, and nothing in that step ever asks the agent for those four actions. The correct absence claim — "this branch never fires" — was available the whole time, to whoever was willing to instrument the mask and watch it not fire, instead of reading the surrounding code and reasoning about what ought to happen.

Treat "there is no X" as a claim that needs a run behind it, not a reading. A branch's absence is provable. It is just not provable by looking.

## Has the strategy space collapsed?

A ladder of strategies that all report different scores can still be exploring exactly one axis — different amounts of the same thing, not different things — and this is invisible from the scoreboard. It needs a measurement, not an argument. The measurement below is cheap enough to run in an afternoon against months of planned content work that assumed the space was wide.

1. **Build a runs × features matrix.** One row per recorded run — every strategy, every seed — one column per feature extractable from it: actions taken by type, resources spent by category, ticks to each milestone, whatever the system logs per run. Standardize each column to zero mean and unit variance so no feature dominates on scale alone.
2. **Run PCA on the matrix** and read the explained-variance ratio of the first component. A single-digit percentage means the runs spread across many genuinely different axes. A number near 100% means almost all the variation in every run is explained by one direction.
3. **Compute the participation ratio** of the first component's loadings: `(Σ loading²)² / Σ loading⁴`. This counts how many features the dominant component actually leans on — low means a handful of features carry it; close to the total feature count means it draws on all of them roughly evenly.
4. **Compute pairwise containment across arms.** For each pair of strategies, treat each arm's set of visited states, or action types, or whatever the domain's natural unit is, as a set, and compute `|A ∩ B| / |A|` and `|A ∩ B| / |B|` for both directions. A containment of `1.000` means one arm's behaviour is a strict subset of the other's — it never did anything the other arm didn't also do.

Multiverse Mages ran this against a ladder that had looked varied on the scoreboard: first principal component `91.4%` of variance, participation ratio `1.19`, cross-arm containment `1.000`. **Strategies do not pick different subsets; they stop at different points along one queue.** An external critique had already made exactly this claim, and against months of planned content work resting on the opposite assumption, one afternoon of measurement was enough to show the critique was right.

## Split your gates by cost

A single merge gate that runs cheap checks and expensive ones together degrades the same way no matter what's in it: the expensive check becomes the bottleneck for every pull request behind it, including the ones with nothing to do with what it's checking.

Multiverse Mages ran a 200-year balance simulation as part of its merge gate. It cost `830` seconds on a quiet machine and `1154` seconds on a busy one, against a `2400`-second runner timeout — close enough to that ceiling to be a risk on its own, and slow enough that, held in the merge gate, it once stacked seven unrelated pull requests waiting behind it in a single day. None of those seven had touched anything the balance gate was checking.

The fix is not to drop the check. It is to split gates by cost: the merge gate carries only what is cheap and deterministic, and the expensive check runs in its own job — parallel, visible to anyone who looks, and **not required to merge**. A regression in the balance run is still visible immediately, on the same commit, at the same resolution it always had. What changes is that nothing waits on it. Seven pull requests with no relationship to game balance should never have been queued behind a single simulation.

## A background loop outlives the reasoning that started it

Nothing in the tooling connects a rule to a running process. Writing down "never do X" does not stop a process already doing X — the prohibition and the loop live in different places, and only one of them knows the other exists.

Multiverse Mages had an auto-merger, built earlier in a session, still running an hour after that same session wrote down a prohibition against exactly what it was doing. It merged a pull request out from under a gated chain that depended on an ordering the auto-merger had no way to know about, because nobody checked whether the thing just prohibited was still running.

Two consequences. First: `pgrep` for the previous instance of a background loop before starting a new one, and the moment a prohibition against some class of loop gets written down, check whether that exact loop is currently running — don't trust the document to have stopped it. Second, and stronger: never build an unattended "both required checks green → merge" drainer. Two pull requests can each be green individually and still produce a red main once both land, because a green check is a statement about the base it ran on, not about the base as it will exist after some other PR merges first. If a merge queue has to run unattended at all, it must merge serially, and confirm the required check is green on main **at main's own current head** between merges — matching the commit that check ran on to the commit main is actually sitting on, not assuming green-then-green means safe-then-safe.
