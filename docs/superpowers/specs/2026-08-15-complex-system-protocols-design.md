# Complex-system protocols — design

**Date:** 2026-08-15
**Repo:** `lizTheDeveloper/shipping-skills`
**Branch:** `complex-system-protocols`
**Source of the material:** the Multiverse Mages build (`lizTheDeveloper/multiverse_mages`), through 2026-08-15. Every learning below is something that build got wrong first and wrote down after.

---

## 1. What this adds and why

`shipping-skills` currently covers the process that keeps up with agent-written code: release branches, versioning, telemetry, verification, documentation, hosting. It has nothing for the case where **the output of the software is a number you then have to trust.**

That case has its own failure modes, and they are not the ones the existing skills catch. A green suite, a clean deploy and a truthful changelog are all compatible with a simulation that has been computing zero for a year. The characteristic failure is not a crash or an outage — it is a plausible number.

Four new skills and one output style. Three existing skills get targeted additions rather than duplicated content.

### Scope boundary

These are about **knowing whether your numbers mean anything.** They are not game-design advice. A skill teaching how to make a strategy game *good* belongs in a different repo; these teach how to find out whether it is.

Worked examples come from a game because that is where the material was earned. The skills are written for any system whose output is a number under uncertainty: simulations, agent-based models, backtests, training loops, economic models, procedural generators.

---

## 2. The organizing idea: a three-phase arc

The original framing for this work was "early build protocol vs in-flight build protocol". That split is real but incomplete, and the gap is the most useful thing in this design.

**You cannot commit a baseline before you know what the numbers should be.** A protocol that opens with "commit your baselines" is unusable on day one, and a team that reads it will either ignore the whole document or commit guesses as thresholds and spend a year rubber-stamping regenerations.

The resolution is that **"golden" names two different artifacts, and only one of them needs numbers:**

| | Needs known-correct values? | Available |
|---|---|---|
| **Identity baseline** — the same input produces byte-identical output | **no** | day one |
| **Value baseline** — this rate lands inside this band | **yes** | only after balance work |

Identity baselines assert *reproducibility*, not correctness. They can be committed before anyone knows what the system should do. Value baselines are claims about the design and cannot exist until the design has been searched.

Multiverse Mages already encodes this admission in its own versioning: MINOR parity, which is the project's balance-validation signal, is **undefined below 0.5.0 — because there is no harness before then.**

So the arc has three phases, not two, and the middle one is where most projects spend most of their life:

```
ground-a-simulation        No numbers exist yet.
                           Build only what needs none.

search-dont-argue          The numbers are unknown and must be found.
                           This is the longest phase.

audit-a-simulation         Numbers exist and are load-bearing.
                           Defend them.

trust-your-instruments     Orthogonal. Runs across all three, and
                           applies to repos with no simulation at all.
```

Each skill states its phase and links to its neighbours. `audit-a-simulation` opens by asking which grounding foundations actually exist, and returns a **stop-and-retrofit** verdict rather than a patch when one is missing — because that is what the retrofit-cost test implies.

### 2.1 Rigor is staged: two axes, not one

The retrofit test says *what to build early*. It does not say *what to gate on*, and conflating the two produces the failure this whole design is meant to avoid — a protocol so heavy at inception that nobody adopts it.

These are independent axes:

| Axis | Governed by | Answer |
|---|---|---|
| **Build now or later?** | retrofit cost | Build now if adding it later invalidates everything measured in between. |
| **Gate every merge, every release, or not at all?** | cost per run, and phase | Gate every merge only on checks that are cheap and deterministic. |

**Before 1.0, the per-merge gate should be light.** Cheap and deterministic only: typecheck, lint, dependency purity, property tests, identity replay. Seconds, not minutes. Everything expensive runs in parallel and **non-blocking**, or per-release.

Two consequences that read as sloppiness and are not:

- **Pre-1.0, breaking a contract is not a merge failure.** It is a named entry in the release notes. That is what `0.x` means, and saying so is honest rather than lax — the contracts are still moving because nobody has finished trying to satisfy them yet.
- **A value-baseline gate cannot block merges before the numbers exist.** MM's 200-year balance gate costs 830–1154 s against a 2400 s runner timeout; held in the merge gate it stacked seven unrelated pull requests in one day. It now runs in its own parallel job, not required to merge — regression visible immediately, nothing blocked. (Expanded in `audit-a-simulation` §5.6.)

**What does not relax pre-1.0:** TDD at the unit level, determinism, and property tests on the arithmetic. Those are cheap per run and expensive to retrofit — they sit on the favourable side of both axes, which is exactly why they are the ones that stay.

This subsection is repeated as a short section in `ground-a-simulation` (§3.3), because a reader who arrives at that skill and reads it as "do all of this before writing anything" will close it.

---

## 3. `ground-a-simulation`

**Phase:** before the first measurement.

**Frontmatter description:**

> Use when starting a simulation, strategy game, agent-based model, backtest, training loop, or any system whose output is a number you will later have to trust. Use before the first measurement is taken — everything here is cheap now and either impossible or baseline-invalidating to retrofit. Also use when auditing a young system for whether it is measurable at all, when deciding how much rigor belongs on a pre-1.0 merge gate, when prototyping a subsystem or UI to work out what an integration test should assert, or when a team says "we can't add baselines yet, we don't know the numbers".

### Sections

**3.1 The retrofit test.** The organizing principle, stated first. If adding it later invalidates every number you have already taken, it belongs in this protocol. This is what makes the document a protocol and not a checklist — it gives a reader a way to decide about items not listed.

**3.2 What you can pin before you know any numbers.** The identity/value table from §2, with the two failure modes it prevents named explicitly:
- Skipping baselines entirely because "we don't know the numbers yet" — which loses determinism permanently, since retrofitting it invalidates everything measured in between.
- Committing value thresholds as guesses, then re-blessing them whenever they fail, which produces a gate that has never once been informative.

Closes with the MM parity example: saying "parity is undefined below 0.5.0" out loud is better than pretending an invariant holds where it cannot.

**3.3 Rigor is staged — what this protocol does *not* ask of your merge gate.** A short version of §2.1, placed early and deliberately, because a reader who takes this skill as "do all of this before writing anything" will close it.

Two axes, not one: **retrofit cost** decides what to *build* now; **cost per run** decides what to *gate* on. Everything in this protocol is on the build axis. Almost none of it belongs on a pre-1.0 merge gate.

Pre-1.0 the per-merge gate carries only what is cheap and deterministic — typecheck, lint, dependency purity, property tests, identity replay. Seconds. Expensive validation runs parallel and non-blocking, or per-release. A broken contract before 1.0 is a named release-note entry, not a merge failure; that is what `0.x` means.

What does not relax: TDD at the unit level, determinism, and the arithmetic property tests. Cheap per run, expensive to retrofit — favourable on both axes, which is why they are the ones that stay.

**3.4 Prototype the subsystem to find the integration test.** The methodology section, and the one that keeps this protocol from reading as ceremony.

TDD holds at the unit level throughout. But **you cannot write the integration test first for a subsystem whose shape you do not yet know**, and a complex system is mostly subsystems whose shape nobody knows. Writing the whole thing end to end — including a throwaway UI — is not a detour around the test. It is how you find out what the test should assert.

State the deliverable plainly: **the prototype's output is the integration test and often the contract. The prototype's code is not the deliverable and should be labelled throwaway.**

MM worked examples, all three of which are the same lesson from different directions:

- **Eleven UI prototypes were built against the real contracts, and produced `interface-findings.md`** — a document of things *the contracts do not carry*. Its own framing is the argument for the practice: *"a finding that lives only in a pull-request description is a finding that evaporates when the branch merges."*
- **The findings carry a status vocabulary worth stealing**: `open` (nobody has decided; the prototype states the options), `defect` (the specified design does not do what it says — needs a change, not a decision), `resolved` (settled during prototyping, recorded so the reasoning survives), and `blocked` (**cannot be settled until a balance number exists**). That last status is the three-phase arc showing up inside a finding table, and it is what stops a prototype from being pressured into inventing a number it has no way to know.
- **The prototype became the integration test, concretely.** The recorded session is committed, and a test re-runs the recorder and compares frames — so any of those numbers going stale is *a red test rather than a silently wrong document*. It has held byte-identical across three `main` merges. That is the whole transition from prototype to gate in one artifact.

And the contract-level version of the same point: four packages in that project are recorded deviations from the architecture document, each with its reasoning, because **the document was drawn before anyone tried to satisfy it.** A design that survives contact is not one that was specified harder up front; it is one that recorded what building it taught.

Link forward to `audit-a-simulation` §5.3: unit tests build their own fixtures, so their lookups always hit. The prototype is how you learn *which boundaries* the assembled-system test needs to watch — this section is the positive framing of that failure.

**3.5 Determinism as a precondition.** Pure `step(state, actions, rng) -> state`. Fixed-point integers, no wall-clock reads, no ambient randomness, no I/O in the rules path. Framed by *why*: not purity or elegance — comparability. A non-deterministic core means no baseline you commit is ever comparable to the next one, and you will not discover that for months.

Carries a copy-pasteable enforcement set, because "be deterministic" is not actionable: restricted-globals lint (`Math.random`, `Date.now`, `new Date`, `performance.now`, `Intl`), a float ban in the rules path, a package-manifest check for zero runtime dependencies, and one shared division helper with defined rounding for negative operands.

**3.6 Stream-split randomness with a permanent ID registry.** Adding a draw in one subsystem must not re-roll any value drawn by any other. IDs are append-only, never reused, never renumbered, enforced by a registry test that names both IDs on a collision and states that committed baselines are invalidated.

The failure mode leads: silent baseline rot, discovered months later, presenting as "balance changed" rather than "the RNG moved".

**3.7 Baselines that cannot re-bless themselves.** Regeneration only by explicit command, never as a test side effect, always producing a reviewable diff. This is the meta-claim that protects every other claim — a suite that silently re-blesses its own baselines reports green forever and detects nothing. A regenerated baseline is a claim that behaviour changed on purpose and reviewers must read it as one.

**3.8 Property tests on the arithmetic, before any behaviour exists.** Division rounding for negative operands, representability bounds, serialize → restore → step round-trip, stacking commutativity and associativity.

Two arguments for why this is a section and not a bullet:

- It is the only thing that catches the **Zeno stall** class before it ships. A `mul(x, k)` that floors to exactly zero for small `x` is invisible in production — the arithmetic is working perfectly — but "for all `x`, `k`: repeated application either converges or moves" is checkable at authoring time.
- **A property test is the positive control for a guard.** MM's `assertRepresentable` spent the project's entire history looking exactly like a NaN guard while being structurally incapable of catching one — every comparison with NaN is false, so a bounds check waves it through. ~3,900 passing tests did not notice; it was found by someone asking. One property — *"for all non-representable inputs, including NaN, this throws"* — kills it on day one.

This section is the concrete mechanism linking `ground-a-simulation` to `trust-your-instruments`.

**3.9 The null before the first real one.** Build the do-nothing agent before you build any strategy. Your score is **margin over null**, not absolute performance.

MM worked example: `permit-then-idle` scored 40/40 against `permissive-breadth`'s 38/40 — the bot that does nothing beat the bot that plays. `uniform-random-legal`, pressing buttons uniformly, ascended 12/12 at a median tick of 707. Eight of ten strategies sat at a rate of exactly 0.0000, which is not ten data points about strategy; it is one data point about there being no ladder.

Without the null from the start, you have no way to tell whether anything you built matters.

**3.10 Pin your metric definitions, with a version.** A metric name is not a definition. "Ticks for 50% of nodes to be lost" does not say the census interval, what happens to something lost and rediscovered, or what to report when half the cohort is still alive at termination. Somebody decides those, and deciding them silently means a later change re-invents them differently and two different quantities get compared under one name.

The mechanism: a table of every free parameter with the question it answers and why that answer; a `definitionVersion` digested with the normative definition and pinned by a test; and the table asserted against the registry **in both directions**, so a constant added to one and not the other fails. That last property is what makes it the only kind of design document that stays true — it cannot go stale without the suite going red.

**3.11 One vocabulary.** Steal the literature's names. An invented metric cannot be compared with the invented metric next door.

MM worked example: five workstreams measured the same thing and named it five ways, and it took five workstreams to notice. The literature's names arrive with thresholds, null models and known failure modes that a home-grown metric does not carry — that is the concrete return, not tidiness. Include the depth-vs-complexity distinction as the canonical case: complexity is how much there is to know; depth is how much there is to get better at.

**3.12 If it has an economy, model the flows first.** Machinations as the formal language. Four known failure modes with known remedies, each of which costs a campaign to discover empirically:

- Source/sink power matching — a scaling source needs a scaling sink, and the diagnostic is **unspent pools**, never aggregate production.
- A converter engine deadlocks; the documented remedy is a weak static engine.
- A producer decision rule that ignores transfers already in flight is the canonical oscillation generator.
- Behaviour-mode classification plus extreme-condition tests, because a purely numerical metric reports an oscillating run and a settled run identically.

### References

- `references/determinism-checklist.md` — the lint rules, manifest check and division-helper contract from 3.3, copy-pasteable.
- `references/metric-definition-template.md` — the free-parameter table format and the two-directional test from 3.8.
- `references/economy-flow-patterns.md` — the Machinations vocabulary and the four failure modes from 3.10.

---

## 4. `search-dont-argue`

**Phase:** the numbers are unknown and must be found. The longest phase.

**Frontmatter description:**

> Use when a design decision has reduced to a number nobody can defend from first principles — a tuning constant, a threshold, a rate, a cap, a cost. Use when a team is arguing about a value, when constants are marked untuned, when setting up a parameter sweep or tuner, or when you have a running system and no idea what its numbers should be.

### Sections

**4.1 The rule.** *If a number has to be figured out, do not figure it out. Search it. The deliverable is the curve, not the value.*

**4.2 Both degenerate ends as controls.** Sweep to the value at which the mechanic does nothing, and the value at which it dominates. Without both ends you cannot tell a well-tuned constant from an inert one.

**4.3 A flat curve is a real finding.** It means the mechanic is theatre and the number was never the constraint. Named as a *success* explicitly and early, because otherwise nobody reports one — a flat curve reads as a failed experiment and gets quietly dropped, and that is how a guessed scalar sitting in a flat region of its own curve becomes indistinguishable from a mechanic that does nothing.

**4.4 Prerequisite: the metric must be able to move.** Stage zero, not optional. An optimiser pointed at a metric that cannot move runs forever reporting progress. MM: 16 of 28 registered metrics are quarantined as structurally incapable of moving. Hard link to `trust-your-instruments`.

**4.5 Common random numbers, and the round-robin trap.** One sweep id for the whole comparison. If run seeds derive from `(rootSeed, sweepId, cellIndex, replicateIndex)` and arms are assigned round-robin, each arm is dealt a **disjoint** set of replicate indexes — so no two arms ever play the same world, and an arm comparison carries a seed-set difference. MM did exactly this at least twice, and a candidate-versus-null ladder is more sensitive to it than a tuner is, because the entire comparison is candidate-against-null on the same worlds.

**4.6 Never cache the null bar.** Doing-nothing's score moves as the system moves. Re-run the nulls every round. A cached bar rots exactly the way stale documents do.

**4.7 Tuning and variety are different searches.** Search a **shared** constant for tuning; search a **per-universe** factor for variety. Conflating them wastes both. MM: pricing all 300 nodes moved containment the *wrong* way, because a cost surface shared by every universe can only reweight terms that already differ between them.

**4.8 An argument survives the evidence.** The closing note. A scalar defended by argument is worse than one defended by a curve, because the argument outlives the refutation. MM's `researchCost` as a pure function of tier was argued for years and refuted in an afternoon.

---

## 5. `audit-a-simulation`

**Phase:** numbers exist and are load-bearing.

**Frontmatter description:**

> Use when a running simulation, game or model is producing numbers you are not sure you can trust — a metric that never moves, a balance result that might be a bug wearing a design outcome's clothes, a strategy space that may have collapsed, a gate that stacks unrelated PRs. Also use when inheriting a system that already has baselines.

### Sections

**5.1 The entry question.** Which grounding foundations do you actually have? Determinism, stream splitting, identity baselines, pinned metric definitions, a null. Returns a **stop-and-retrofit** verdict where one is missing, not a patch — this follows directly from the retrofit test, and stating it as a verdict is what stops a reader from treating the rest of the document as a workaround.

**5.2 The silent zero.** The characteristic bug class of a numeric system. Two independent routes to the same destination:

```
a lookup misses
  -> undefined enters arithmetic
  -> NaN comes out
  -> it is written to an integer column
  -> the typed array coerces NaN to 0
  -> the mechanic contributes nothing, forever
```

and, with no NaN involved at all: division rounding toward negative infinity means a small per-tick increment floors to exactly zero and the quantity never moves again — the **Zeno stall**, with the arithmetic working perfectly.

Nothing throws. Nothing is corrupt. **The result is a legitimate-looking zero that reads as a balance outcome rather than as a bug.** Whoever sees the intermediate value calls it NaN contamination; whoever sees the stored value calls it a quantity that fell to zero. Same defect, two complaints.

**5.3 Why the unit suite is structurally blind to it.** Not for want of tests. **A unit test builds its own fixture, so its lookups always hit.** It passes a record it just constructed and an id it just interned. Production looks the same values up in an assembled registry where a key may not resolve and a caller may pass an empty array. Every one of those tests can be correct and green while the assembled system computes zero.

The missing artifact is never *more* unit tests. It is tests of a different category: run the assembled system and watch the boundaries.

**5.4 Absence claims require execution.** You cannot prove "there is no X" by reading. MM: "unmasking four actions during engagement moves every balance baseline" was asserted confidently from reading the code and was false — instrumenting the mask showed the branch is evaluated **zero** times, because raids resolve inside one step and nothing asks the agent.

**5.5 Has the strategy space collapsed?** A measurement, not an argument, with a runnable recipe: PCA over the runs × features matrix, participation ratio, and pairwise containment across arms.

MM worked example: first principal component 91.4% of variance, participation ratio 1.19, cross-arm containment 1.000. *Strategies do not pick different subsets; they stop at different points along one queue.* An external critique had claimed exactly this and the campaign's thesis was insufficient — one afternoon of measurement against months of planned content work.

**5.6 Split your gates by cost.** The merge gate must be fast; the expensive gate runs in parallel, visible, and **not required to merge**. MM: the 200-year balance gate costs 830 s on a quiet machine and 1154 s on a busy one against a 2400 s runner timeout; held in the merge gate it stacked seven unrelated pull requests in a single day. Split out, a regression is visible immediately without blocking unrelated work.

**5.7 A background loop outlives the reasoning that started it.** `pgrep` for the previous one before starting any loop, and when you write down a prohibition, immediately check whether the prohibited thing is currently running — nothing in the tooling connects a rule to a running process. MM: an auto-merger built earlier in a session was still running an hour after the same session wrote a prohibition against exactly that, and merged a PR out from under a gated chain.

Never build an unattended "both required checks green → merge" drainer: two PRs can each be green and produce a red main, because a green check is a statement about the base it ran on.

---

## 6. `trust-your-instruments`

**Orthogonal.** Deliberately not simulation-scoped — this is the one that will be invoked from repos with no model in them, because it is about scripts, gates, aggregators and analysis tooling generally.

**Frontmatter description:**

> Use when a check, script, aggregator, gate or analysis tool reports a result — especially a negative result — and before acting on it. Use when a metric reads as a healthy constant, when a guard has never fired, when a CI poller says nothing is green, when a knob appears to do nothing, or when writing any script that answers a question about an input it located itself.

### Sections

**6.1 When a check reports the negative case, confirm the check works.** The core rule, stated first.

**6.2 Positive controls.** Every checker gets an input it must accept. A checker that has only ever been observed rejecting has not been observed working.

**6.3 The third exit.** `0` open, `42` shut, `1` the probe is broken. Folding "broken" into "no" is the failure mode, and it is the default one because both produce a non-zero exit. Reference implementation: MM's `scripts/w117-gate-check.sh`.

**6.4 Locate input by name, never by shape or by glob.** The catalogue — five instances from a single night, none of which threw, all of which reported confidently:

- An aggregator globbing a directory folded **any** run's output, not *this* run's, so a second invocation ate the first's records at a different `--ticks`. The archive was well-formed and every number plausible; the only symptom was a denominator that did not match the flag.
- An aggregator locating input by **shape** rather than name found the wrong input: records were committed as CSV, the analyser read `.runs.ndjson`, and a before/after comparison silently compared the new run against itself.
- `awk '{print $2}'` on `gh pr checks` output. Columns are tab-separated and the first contains spaces, so `Verify (pinned Node)` splits into three fields and `$2` is `(pinned`. A merge poller ran ten minutes reporting nothing green while both checks were green.
- jq's `//` on an empty string. A running job's `conclusion` is `""`, not `null`, and `//` falls through only on `null` and `false`. A watcher printed `not-started` for twenty consecutive polls while the run was in progress.
- A CI gate reading the newest run instead of the run for `origin/main`. "Main is green" was a statement about whichever commit happened to be newest.

**6.5 A guard that cannot fire.** `assertRepresentable`: correct-looking for the project's entire history, in the most-reviewed file in the repository, against ~3,900 passing tests. Every comparison with NaN is false, so a bounds check waves it through. Found by someone asking, not by a test. Cross-link to the property-test remedy in `ground-a-simulation` §3.8.

**6.6 A metric that cannot move.** The output side. An axis whose descriptor cannot move produces a one-cell archive that looks like a finding. Prove the descriptor can move before pointing anything at it, human or optimiser. MM: 16 of 28 registered metrics quarantined; ten instruments read as healthy constants while being structurally incapable of moving.

**6.7 Prove the knob moves the system.** The input side, and the dual of 6.6. **Amplify every authored magnitude by ×100, re-run, diff. Byte-identical means wired and inert.**

MM worked example, verbatim:

| primitive | lessons | research | verdict |
|---|--:|--:|---|
| control | 1867 | 4571 | — |
| research-rate ×100 | 1779 | 4541 | moves |
| teach-rate ×100 | 1288 | 4564 | moves — −31% |
| scribe-rate ×100 | 1414 | 4407 | moves |
| lifespan ×100 | 1867 | 4571 | **byte-identical** |
| fertility ×100 | 1867 | 4571 | **byte-identical** |

Three academic rates are genuinely live, and `teach-rate` is the strongest result — it had previously been recorded as the null measured most confidently, and it moves lessons by nearly a third.

`lifespan` and `fertility` are **wired and inert**.

The detail that earns this a section rather than a bullet: **a static consumption check names a consumer for both, and passes.** "Is this value read?" and "does this value change anything?" are different questions, they come apart silently, and the gate that looks like it covers you is the one that does not. The author's own summary is the closing line: *no gate I used could have seen it.*

Name the connection to `search-dont-argue` §4.2 explicitly: ×0 and ×100 are the **both degenerate ends as controls** rule applied to *wiring* rather than tuning. Ablation and amplification are one instrument pointed two directions.

### References

- `references/probe-template.sh` — the three-exit skeleton from 6.3.
- `references/known-false-checkers.md` — the 6.4 catalogue, structured so a reader can append their own.

---

## 7. `caveman` — output style

A new artifact type for this repo. Ships at top-level `output-styles/caveman.md`.

**Provenance:** currently local to the Multiverse Mages checkout at `.claude/output-styles/caveman.md`, active via `settings.local.json`. It is good and it is tested by daily use; it does not travel because it lives in one project.

**Copied as-is, with three edits:**

1. Replace the two Multiverse-Mages-specific path examples (`docs/design/vision.md` §7 and similar) with generic ones. The repo is deliberately project- and vendor-neutral.
2. Note in the README that it is the style the worked examples in these skills were produced under.
3. Nothing else. Do not rewrite it — the terseness is the point and an edit pass will pad it.

**Why it belongs in this repo,** and the framing for the README: every skill here is about knowing what you own. Caveman is about **not manufacturing a second copy of a fact that can rot** — cite the file, do not retell it; name the section, do not summarise it. That is the same rule the rest of the repo applies to infrastructure, applied to prose.

---

## 8. Edits to existing skills

Three learnings belong in skills that already exist. Adding them there rather than duplicating them keeps each skill the single place its topic lives.

| Skill | Addition |
|---|---|
| **`version-and-claim`** | The claim's **third clause**: a release claim needs the disproving measurement *and whether that measurement is actually collected yet*. The existing skill has the first two. Plus MINOR parity as a worked pattern — even = balance-validated, odd = in flight; every capability ships twice, landing on an odd MINOR and being *promoted* to the next even one when its baselines are green; the even release is earned, not scheduled; the gate is enforced in CI, not intended, because a version scheme that relies on someone remembering lies within a month; and parity is undefined below the version where the harness first exists, said out loud. |
| **`detect-drift`** | **A document is not a ref for the code it describes.** Date every measurement and name the ref it was taken on — an undated measurement in the present tense reads as current for as long as it survives. Worked case: `vision-audit.md` asserted a figure in the present tense and tagged it `[executed]`, while a test file on the same commit carried the same figure under "this is a historical record, not the current measurement". Two documents on `main` contradicting each other, the misleading one was the one people read, and it cost two agents a full investigation each. Plus: **index a docs directory by kind** — authoritative / measured / deferred — because two audits were commissioned in that project that re-derived work already sitting in the directory, invisible. |
| **`run-a-campaign`** | Measure whether the space has dimensions **before** committing a campaign to filling it. A pointer into `audit-a-simulation` §5.5. MM's content campaign was aimed at a space measured afterwards at one effective dimension. |
| **`release-process`** | **Gate weight is staged.** Pre-1.0 the per-merge gate carries only cheap deterministic checks; expensive validation runs parallel and non-blocking. Pre-1.0, a broken contract is a named release-note entry, not a merge failure. A pointer into §2.1 and `audit-a-simulation` §5.6, with the seven-stacked-PRs case as the concrete cost of getting it wrong. |

---

## 9. README changes

1. Four new rows in the skills table.
2. A short **three-phase arc** subsection under the table — the diagram from §2 — so the relationship between the three simulation skills is visible without opening them, and so `trust-your-instruments` is clearly marked as usable on its own.
3. An **output styles** section for caveman, with the framing from §7.
4. Updated install block:

```bash
git clone https://github.com/lizTheDeveloper/shipping-skills.git
cp -r shipping-skills/skills/*         ~/.claude/skills/
cp -r shipping-skills/output-styles/*  ~/.claude/output-styles/
```

5. One paragraph extending "the problem they solve" to the numeric case: the existing list is about not knowing what you have; this adds not knowing whether what you measured is real.

---

## 10. Deliberate non-goals

**No strategy-game design skill.** Everything genuinely game-shaped here — the null agent, dimensionality collapse, economy flows — reads better as the general form with a game example. Design advice is a different repo's job.

**Not folded into `verify-release`.** That skill is about a human walking a preview URL. These are about a machine reporting a number. Different failure modes, different reader.

**No new tooling, scripts or CI in this change.** The reference files are templates and catalogues. Anything executable that ships must be a skeleton the reader adapts, not a dependency.

---

## 11. Constraints on the writing

- Match the existing house style: folded `description: >` frontmatter, `# Title`, prose-first with bold on the load-bearing noun, tables only when comparing more than two things on more than one axis.
- **Every number in these skills is a measurement from a named build.** Carry the figure and say where it came from. A skill that says "we found metrics that could not move" teaches nothing; "16 of 28 registered metrics are quarantined" teaches the scale of the problem.
- **Lead each section with the failure mode, not the remedy.** The remedies are mostly obvious once the failure is believed, and the failures are the part that is hard to believe in advance.
- Vendor- and project-neutral in the instructions; specific in the examples.
- Do not soften the cases where the project was confidently wrong. Those are the parts that transfer.
- **`ground-a-simulation` must not read as ceremony.** It is the skill most at risk of being closed on first contact, because its subject is work done before there is anything to show. §2.1 and §3.3 are load-bearing against that: the protocol says what to *build*, explicitly says the pre-1.0 merge gate stays light, and explicitly licenses prototyping a whole subsystem before any integration test exists. If a draft of that skill reads as "do all of this before writing anything", it is wrong and those two sections need to be earlier and louder.

---

## 12. Deliverables

**New:**
- `skills/ground-a-simulation/SKILL.md` + 3 references
- `skills/search-dont-argue/SKILL.md`
- `skills/audit-a-simulation/SKILL.md`
- `skills/trust-your-instruments/SKILL.md` + 2 references
- `output-styles/caveman.md`

**Edited:**
- `skills/version-and-claim/SKILL.md`
- `skills/detect-drift/SKILL.md`
- `skills/run-a-campaign/SKILL.md`
- `skills/release-process/SKILL.md`
- `README.md`
