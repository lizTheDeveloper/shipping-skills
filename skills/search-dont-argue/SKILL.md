---
name: search-dont-argue
description: >
  Use when a design decision has reduced to a number nobody can defend from
  first principles — a tuning constant, a threshold, a rate, a cap, a cost. Use
  when a team is arguing about a value, when constants are marked untuned, when
  setting up a parameter sweep or tuner, or when you have a running system and
  no idea what its numbers should be.
---

# Search, Don't Argue

**Phase 2 of three, and the one you live in longest.** The numbers are unknown and have to be found. Grounding the system is `ground-a-simulation`; defending the numbers once they are load-bearing is `audit-a-simulation`.

*Figures below are drawn from the `lizTheDeveloper/multiverse_mages` build, measured August 2026, each from its own separate recorded run.*

If a number has to be figured out, do not figure it out. **Search it. The deliverable is the curve, not the value.**

## The rule

A meeting that argues a tuning constant to consensus produces a number that is only as durable as the most confident person in the room — and the next reorg, the next designer, the next "this feels off" will re-argue it from scratch, because nothing about a consensus number is checkable. Two people who disagree about a cost, a rate, or a cap are not actually disagreeing about the number. They are disagreeing about a curve neither of them has looked at.

So don't resolve the argument. Replace it. Run the system across the range the constant could plausibly take, plot whatever the constant is supposed to affect, and read the value off the curve. The deliverable that comes out of this phase is never a number defended by reasoning — it is a number read off a plot, with the plot committed alongside it so the next person doesn't have to re-argue, only re-read.

## Both degenerate ends as controls

Sweeping only near the value a team already suspects is right tells you nothing about whether that value matters at all. A sweep confined to a plausible band can produce a smooth, reasonable-looking curve through a mechanic that is inert everywhere in that band and would look identical whether the constant did anything or not.

The fix is to sweep past both edges on purpose: the value at which the mechanic does **nothing** — effectively switched off — and the value at which it **dominates** everything else in the system. Only with both extremes in view can a curve in the middle be read as *tuned* rather than merely *plotted*. A constant that looks the same at both extremes was never the lever anyone thought it was, and no amount of sweeping the middle would have shown that.

## A flat curve is a real finding

A flat curve is a **success**, not a failed sweep — say so before doing anything else with it. It means the mechanic is theatre: the number was never the constraint, and no value in the searched range would have changed the outcome. That is exactly as informative as a curve with a clear knee in it, and it is the harder of the two to report, because a flat line looks like the experiment didn't work rather than like the experiment worked and told you the honest answer.

This is where the finding usually dies. A flat curve gets read as "the sweep didn't find anything," filed under negative results, and dropped — and dropping it is how a guessed scalar sitting in a flat region of its own curve becomes permanently indistinguishable from a mechanic that does nothing at all. Nobody re-argues a number that was never shown to be flat. Report the flat curve with the same weight as a curve with a knee in it, because it is answering the same question: does this number matter, yes or no.

## Prerequisite: the metric must be able to move

This is stage zero, not an optional check before the real work starts. A sweep — or an optimiser, or a tuner — pointed at a metric that structurally cannot move will run for as long as you let it, reporting a flat line at every step, and there is no way from inside the sweep to tell that flat line apart from a real finding. 16 of 28 registered metrics were quarantined as structurally incapable of moving at all; every one of those would have produced a technically-correct, entirely useless flat curve if searched before anyone checked.

Prove the metric can move before pointing a sweep at it. See `trust-your-instruments`, under **A metric that cannot move**, for how to check that before spending a run on it.

## Common random numbers, and the round-robin trap

A sweep that compares arms across different seeds is comparing seeds, not arms — and it will look exactly like a fair comparison the whole time, because every individual run is deterministic and reproducible. The failure isn't in any one run; it's in how the runs are assigned to arms.

The concrete shape it takes: run seeds are derived deterministically from a tuple like `(rootSeed, sweepId, cellIndex, replicateIndex)`, which is exactly the right design for reproducibility — the same cell of the same sweep always regenerates the same seeds. The trap is in how `replicateIndex` gets handed out. Assign arms round-robin over the replicate indexes — arm A gets `0, 2, 4, ...`, arm B gets `1, 3, 5, ...` — and each arm now plays a **disjoint** set of worlds. No replicate index is ever shared between arms, which means no two arms ever play the same world, which means the comparison is silently carrying a seed-set difference on top of whatever difference the arms were supposed to isolate. A candidate that wins might be winning because its worlds happened to be easier.

Use **common random numbers**: the same replicate index means the same world for every arm, so arm A's run 3 and arm B's run 3 differ only in the arm. Round-robin assignment over a shared index pool defeats this by construction, because it hands every arm a different subset of the pool instead of the same one. A candidate-versus-null ladder is more sensitive to this than a general tuner is, since the entire comparison is candidate-against-null on what is supposed to be the same set of worlds — if the worlds differ, the ladder is measuring the seed split, not the candidate.

## Never cache the null bar

A cached null score is a claim about a system that no longer exists. The do-nothing baseline's score moves every time anything else in the system moves — a rebalanced rate, a changed cost, a new mechanic — because the null is not exempt from those changes, it just doesn't react to them on purpose. A null bar computed once and reused across every subsequent sweep is being compared against a system it never actually ran on.

Re-run the null every round, alongside whatever candidate is being swept. This rots the same way a stale document rots: it reads as current for as long as nobody checks the date, and by the time someone notices the null hasn't moved in three rounds, every comparison made against it in between is in question.

## Tuning and variety are different searches

These are two different questions, and running one search to answer both wastes the search and answers neither. **Tuning** asks what value a constant should take, shared across the whole system — search a single shared constant. **Variety** asks how different instances of something should differ from each other — search a per-instance factor, one value per instance, not one value for all of them.

A shared constant swept for tuning can only ever move every instance the same amount, in the same direction, at the same time. It cannot introduce variety, because it has no way to treat one instance differently from another — and searching it as if it could produces a curve that looks like it's exploring diversity while it is actually just rescaling everything uniformly. Multiverse Mages priced all 300 nodes — assigned every node in its knowledge grid a research cost — with exactly this conflation: a shared cost surface applied uniformly, searched to move containment (the domain outcome the sweep was aimed at — how confined species stayed to their own territory, not the `|A ∩ B| / |A|` set-overlap metric `audit-a-simulation` defines under its own name), and containment moved the **wrong way** — because a term shared across every universe can only reweight terms that already differ between universes, not create a difference where none existed. The fix was a per-universe factor, not a better-tuned shared one.

## An argument survives the evidence

A scalar defended by argument is worse than one defended by a curve, because the argument outlives its own refutation. A curve is either read correctly or it isn't — once someone checks it, the checking is over. An argument has no such property: it can be re-argued after being refuted, by the same person, because nothing about losing an argument stops the loser from believing it. Multiverse Mages' `researchCost`, defined as a pure function of tier, was argued for **years** on first-principles grounds — and refuted in an **afternoon**, the moment someone actually swept it.

That is the whole case for this skill. Not that arguments are wrong more often than searches — they aren't, necessarily — but that a search, once run, stays refuted. An argument, once lost, does not.
