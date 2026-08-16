---
name: ground-a-simulation
description: >
  Use when starting a simulation, strategy game, agent-based model, backtest,
  training loop, or any system whose output is a number you will later have to
  trust. Use before the first measurement is taken — everything here is cheap
  now and either impossible or baseline-invalidating to retrofit. Also use when
  auditing a young system for whether it is measurable at all, when deciding how
  much rigor belongs on a pre-1.0 merge gate, when prototyping a subsystem or UI
  to work out what an integration test should assert, or when a team says "we
  can't add baselines yet, we don't know the numbers".
---

# Ground A Simulation

**Phase 1 of three.** Here, no numbers exist yet — so build only what needs none. When the numbers are unknown and must be found, that is `search-dont-argue`. When they exist and are load-bearing, that is `audit-a-simulation`.

## The retrofit test

A team with no numbers yet reaches for the wrong default in both directions: either it defers everything ("we'll add rigor once we know what good looks like") or it front-loads everything ("commit thresholds now, tune them later"). Both fail the same way — the first loses reproducibility permanently, the second produces a gate nobody trusts.

The question that actually sorts the list: **if you add this after the fact, does it invalidate every number you already measured?** If yes, build it now, before there is anything to invalidate. If no — if it can be bolted on later without disturbing what came before — it can wait.

Determinism fails this test hard: a core that reads the wall clock or calls an unseeded random function produces numbers that were never comparable to begin with, and there is no way to go back and make the last six months of measurements comparable to the seventh. A dashboard, a UI, a report format — none of these invalidate anything if added late. This is what makes the retrofit test a protocol and not a checklist: it gives a reader a way to decide about the item that isn't on the list, not just the ones that are.

## What you can pin before you know any numbers

"Golden" names two different things, and only one of them needs numbers:

| | Needs known-correct values? | Available |
|---|---|---|
| **Identity baseline** — the same input produces byte-identical output | no | day one |
| **Value baseline** — this rate lands inside this band | yes | only after balance work |

An identity baseline asserts *reproducibility*: replay the same seed and actions, get the same bytes back. It says nothing about whether the result is any good, which is exactly why it needs no numbers. A value baseline asserts *correctness against a design intent* — this rate should land between these two figures — and that intent does not exist until someone has searched for it.

Two failure modes this table exists to stop:

- **Skipping baselines entirely** because "we don't know the numbers yet." This treats identity and value baselines as one thing, throws out the one that costs nothing, and loses determinism permanently — retrofitting it later invalidates everything measured in the gap.
- **Committing value thresholds as guesses**, then re-blessing them every time they fail. This produces a gate that has never once been informative, because a threshold nobody defended cannot be violated in any way that means something.

Multiverse Mages states this admission out loud rather than pretending an invariant holds where it can't: its MINOR version parity is the project's balance-validation signal, and parity is **undefined below 0.5.0**, because there is no harness before then. Saying "this claim doesn't apply yet" is better than a green checkmark with nothing behind it.

Metric definitions are the same shape at a smaller scale — a name like "ticks to 50% loss" looks pinned and isn't, until every free parameter it hides has an answer on record. See **Pin your metric definitions, with a version**, below.

## Rigor is staged — what this does not ask of your merge gate

Everything above is about what to *build*, decided by the retrofit test. It says nothing about what to *gate on*, and a reader who conflates the two will read this whole document as "do all of this before writing anything" and close it. These are two different axes.

**Retrofit cost decides what to build now.** Build it now if adding it later invalidates everything measured in between — that's the section above.

**Cost per run decides what to gate on, and pre-1.0 the answer is: almost none of this.** Before 1.0, a per-merge gate should carry only what is cheap and deterministic — typecheck, lint, dependency purity, property tests, identity replay. Seconds, not minutes. Everything expensive runs in parallel and non-blocking, or once per release, never on every merge.

Two consequences of that split that read as sloppiness and aren't:

- **Pre-1.0, breaking a contract is not a merge failure.** It's a named entry in the release notes. That is what `0.x` means — the contracts are still moving because nobody has finished trying to satisfy them yet, and gating on a moving target just teaches people to route around the gate.
- **A value-baseline gate cannot block merges before the numbers exist**, and shouldn't block them even once they do if it's slow. Multiverse Mages' 200-year balance gate costs `830`–`1154` seconds against a `2400`-second runner timeout; held in the merge gate, it once stacked seven unrelated pull requests waiting behind it in a single day. It now runs in its own parallel job, not required to merge — a regression is visible immediately, and nothing is blocked waiting to find out.

What does **not** relax pre-1.0: TDD at the unit level, determinism, and property tests on the arithmetic. Those are cheap per run and expensive to retrofit — favourable on both axes at once, which is exactly why they're the ones that stay.

## Prototype the subsystem to find the integration test

TDD holds at the unit level throughout — that never relaxes. But TDD assumes you know what the integration test should assert, and **you cannot write that test first for a subsystem whose shape you don't yet know.** Most of a complex system is subsystems like that. Insisting on the integration test before the prototype, for a shape nobody has seen yet, doesn't produce rigor — it produces a test that asserts the first guess and gets rewritten three times.

Building the whole thing end to end, including a throwaway UI, is not a detour around the test. **It is how you find out what the test should assert.** The prototype's output is the integration test and often the contract; the prototype's *code* is not the deliverable and should be labelled throwaway so nobody mistakes it for the real implementation later.

Multiverse Mages ran this twice, at two different scales, and both worked the same way:

- Eleven UI prototypes were built against the real contracts, and produced a single document of things the contracts do not carry — findings a spec review would never have surfaced, because the gaps only showed up under a real hand trying to use the interface. The document's own framing is the argument for building the prototypes at all: **"a finding that lives only in a pull-request description is a finding that evaporates when the branch merges."**
- Four packages in that project's architecture are recorded deviations from the document that was supposed to specify them, each with its reasoning attached, because the document was drawn before anyone tried to satisfy it. A design that survives contact isn't one that was specified harder up front — it's one that recorded what building it taught.

The findings document used a four-status vocabulary worth stealing wholesale:

- **`open`** — nobody has decided yet; the prototype lays out the options rather than picking one.
- **`defect`** — the specified design does not do what it claims. This needs a change, not a decision.
- **`resolved`** — settled during prototyping, recorded so the reasoning survives the next reader who wonders why it's built this way.
- **`blocked`** — cannot be settled until a balance number exists. This status is the three-phase arc showing up inside a single finding: it's what stops a prototyper from being pressured into inventing a number nobody has any way to know yet, and it's the honest way to say "not now" instead of guessing.

The strongest version of this pattern closes the loop entirely: a recorded prototype session, committed as data, with a test that re-runs the recorder and diffs the frames against it. Any of those numbers going stale is now a red test instead of a silently wrong document — it held byte-identical across three separate merges to the main branch. That's the whole transition from prototype to gate, in one artifact.

## Determinism as a precondition

A simulation core built on a wall clock, an unseeded RNG call, or floating-point drift produces numbers that were never comparable in the first place — and you will not find out for months, because every individual run still looks plausible. It presents as "balance seems to have shifted" long after the actual cause (a library update that changed float rounding, a clock read that leaked into a hash) has scrolled out of anyone's memory.

The target is a pure function: `step(state, actions, rng) -> state`. Fixed-point integers, not floats, in anything on the rules path. No wall-clock reads. No I/O. No ambient randomness — every draw comes from an RNG that was itself derived from the seed, never from a global.

This is not about purity for its own sake. It's about **comparability**: a non-deterministic core means no baseline you commit is ever comparable to the next one, silently, and the loss doesn't show up as an error — it shows up as noise nobody can subtract out. Once the noise is in your baselines, you're stuck asking whether every future diff is signal or artifact.

"Be deterministic" isn't actionable on its own; it needs enforcement or it decays the first time someone reaches for `Date.now()` under a deadline. See `references/determinism-checklist.md` for a copy-pasteable set: restricted-globals lint rules for the usual leaks, a float-literal ban scoped to the rules path, a package-manifest check for zero runtime dependencies, and the shared division-helper contract with the property test that pins its rounding.

## Stream-split randomness, with a permanent ID registry

Adding a random draw to one subsystem must never re-roll a value drawn by any other subsystem. Get this wrong and the failure mode is silent: nothing crashes, nothing looks wrong in review, and a change to, say, weather generation quietly reshuffles combat outcomes three subsystems away — because both were drawing from the same stream and the new draw shifted every call that came after it.

The fix is to split the RNG into named, permanent streams — one per subsystem — each identified by an ID that is append-only and never reused, never renumbered, never repurposed even after the subsystem it named is deleted. Enforce this with a registry test, and make the failure message name **both** colliding IDs and state plainly that every committed baseline is now invalidated — not just "ID collision", which reads as a lint nit rather than the baseline-destroying event it actually is.

## Baselines that cannot re-bless themselves

A regeneration command that a test suite can invoke on its own is a suite that reports green forever and detects nothing, because every failure becomes an update instead of a signal. This is the failure mode underneath every other guarantee in this document: it doesn't matter how carefully a baseline was set if the mechanism that keeps it can quietly reset it.

Baselines regenerate **only by explicit, human-invoked command**, never as a side effect of getting a test to pass, and every regeneration produces a reviewable diff — not a silently overwritten file. A regenerated baseline is a claim that behaviour changed on purpose, and it has to be reviewable as exactly that claim, with the diff standing in for the argument. Treat "the fixture didn't match, so I regenerated it" as a sentence that should never appear in a commit message — if it's true, the commit is hiding a behaviour change behind a maintenance chore.

## Property tests on the arithmetic

A property test on the core arithmetic, written before any behaviour exists, catches a class of bug that unit tests structurally cannot see: the one where every individual example passes and the general case is still broken.

The canonical instance is the **Zeno stall**: a function like `mul(x, k)` that floors to exactly zero for some small `x` and `k > 0`. Every example anyone thinks to write by hand passes — `mul(100, 0.5)` works fine, `mul(1, 0.5)` works fine. In production the bug is invisible too: the arithmetic is executing correctly, just against inputs where the correct floored answer happens to be zero, forever, and the value being modelled never moves again. What catches it is the property, stated once: *for all `x`, `k`, repeated application either converges or moves* — checkable at authoring time, long before anyone notices a value has been silently pinned at zero for a hundred simulated ticks.

The general form of the lesson: **a property test is the positive control for a guard.** A guard that has only ever been observed catching hand-picked examples has not been observed working on the case it actually exists to catch. Multiverse Mages' `assertRepresentable` sat in the most-reviewed file in the codebase, looking exactly like a NaN guard, for the project's entire history — passing against roughly `3,900` green tests, none of which noticed that every comparison with NaN is false, so a bounds check waves a NaN straight through without ever tripping. One property, stated once — *for all non-representable inputs, including NaN, this throws* — kills it on day one instead of on whichever day someone finally thinks to ask. See `trust-your-instruments`, under **A guard that cannot fire**, for the full account of how it was found.

## The null before the first real one

Build the do-nothing agent before you build any strategy. Score everything else as **margin over null**, not as an absolute number — an absolute score tells you nothing about whether the system rewards playing at all.

Multiverse Mages built this late enough to be embarrassed by it: `permit-then-idle`, a bot that grants permissions and then does nothing else, scored `40/40`. `permissive-breadth`, a bot that actually plays, scored `38/40` — the bot that does nothing beat the bot that plays. Separately, `uniform-random-legal` — a bot that presses buttons uniformly at random among whatever is legal — ascended `12/12` of its runs, at a median tick of `707`. And across one batch of strategies, eight of ten sat at a win rate of exactly `0.0000`. That isn't ten data points about strategy quality; it's one data point about there being no ladder to climb, repeated ten times.

None of these are findings about the strategies. They're findings about the system, visible only because a null existed to compare against. Without it from the start, there is no way to tell whether anything built afterward matters at all — a strategy that beats a non-existent baseline hasn't beaten anything.

## Pin your metric definitions, with a version

A metric name is not a definition. "Ticks for 50% of nodes to be lost" sounds precise and settles nothing: it doesn't say how often the cohort is counted, what happens to something that was lost and then rediscovered, or what to report when half the cohort is still alive at the moment the run ends. Somebody decides those questions whether or not the decision gets written down — the difference is only whether the next person to touch the metric reinvents the answer differently, and two incompatible quantities end up compared under one name without anyone noticing the name stopped meaning one thing.

The mechanism: a table of every free parameter the metric name hides, with the question it answers and why that answer rather than another one; a `definitionVersion`, digested from the normative definition text and pinned by a test, so a change to what the metric means is a deliberate, reviewable act instead of a silent edit; and the table asserted against the registry of constants **in both directions** — a constant that exists in the registry with no row in the table fails, and a row in the table for a constant the registry no longer declares fails too.

That two-directional assertion is what earns this a section: it is the one kind of design document that **cannot go stale without the suite going red**. See `references/metric-definition-template.md` for the table format, the version mechanism, and three worked rows.

## One vocabulary

Steal the literature's names for the things you're measuring, rather than inventing your own. An invented metric can't be compared to the invented metric sitting next to it, even when they're measuring the same underlying thing, because nothing forces two authors' private vocabularies to line up.

Multiverse Mages had five workstreams independently measure the same quantity and name it five different ways — and it took all five workstreams comparing notes to notice they'd been computing the same thing. The literature's names are worth stealing because they arrive already loaded with thresholds, null models, and known failure modes that a home-grown name carries none of — that's the concrete return, not a tidiness preference.

The canonical case worth pinning explicitly: **complexity is how much there is to know; depth is how much there is to get better at.** A system can be complex without being deep — many rules, no skill ceiling — or deep without being complex — few rules, an unbounded skill ceiling. Conflating them under one word (usually "complexity") hides which one a design change actually moved.

## If it has an economy, model the flows first

A resource economy that nobody modelled before implementation reliably produces the same four failures, and each one costs a full playtest campaign to discover empirically instead of a diagram to discover on paper. Machinations — a formal diagram language for resource flows built from sources, sinks, pools, converters and traders — is a way to find them before any code exists.

- **Source/sink power mismatch.** A source that scales needs a sink that scales with it, or the excess has nowhere to go. The diagnostic that catches this is **unspent pools sitting idle**, never aggregate production numbers — production can look healthy while the sink downstream of it is already saturated.
- **Converter engine deadlock.** A converter loop with no slack anywhere in it can lock every participant waiting on inputs nobody is producing. The documented remedy is a deliberately weak static engine — some baseline trickle of input that never depends on the loop resolving.
- **Producer decisions blind to in-flight transfers.** A producer that decides how much to make by looking only at current stock, and ignores what's already committed and en route, is the canonical oscillation generator: it overproduces because the incoming shipment hasn't landed yet, then underproduces once it does, forever.
- **Behaviour-mode classification, plus tests at extreme conditions.** A purely numerical summary metric — mean stock, total throughput — reports an oscillating economy and a settled one identically if their averages happen to match. Only a check that classifies the *shape* of the trajectory, not just its average, tells the two apart.

See `references/economy-flow-patterns.md` for the vocabulary and all four patterns worked as shape → symptom → remedy.
