# Economy flow patterns

A catalogue to check a designed economy against, not a dependency. The
vocabulary is Machinations — a diagram language for resource flows built
from sources, sinks, pools, converters and traders — from Joris Dormans,
*Engineering Emergence: Applied Theory for Game Design*, ILLC Dissertation
Series DS-2012-12, licensed CC BY-NC 3.0 NL. The four failure modes below
are the ones worth checking for before any code exists, because each one
otherwise costs a full playtest campaign to discover empirically.

Each pattern: shape, then the symptom that shows up in play, then the
remedy.

## Source/sink power mismatch

**Shape.** A source's output rate scales with some game variable (player
count, tech level, time) but the sink that's supposed to absorb that
output was sized for the source's *starting* rate and never revisited.

**Symptom.** Aggregate production numbers look fine — even good, the
economy appears to be "producing more" over time, which reads as success
in a dashboard. The actual tell is **unspent pools growing without
bound** — resource sitting idle because there is nowhere for it to go.
Checking aggregate production instead of pool occupancy is the mistake
that lets this ship: production being high is exactly what a mismatched
source looks like right up until the sink is saturated.

**Remedy.** Size the sink to scale with the same variable the source
scales with, and diagnose by watching pool levels over a long run, not by
watching output totals.

## Converter engine deadlock

**Shape.** A converter loop — A produces the input B needs, B produces the
input A needs — with no slack anywhere in the loop and no external input
that doesn't depend on the loop already running.

**Symptom.** The loop locks at zero. Every participant is waiting on an
input that only the other participant produces, and neither can start
because starting requires the other to have already started.

**Remedy.** A deliberately weak static engine: some baseline trickle of
input to the loop that does not depend on the loop resolving anything.
It doesn't need to be large — it only needs to exist, so the loop has a
way to bootstrap itself out of zero.

## Producer decision rule ignoring in-flight transfers

**Shape.** A producer decides how much to make next by looking only at
*current* stock level, with no visibility into shipments already committed
and en route.

**Symptom.** This is the canonical oscillation generator. The producer
sees low stock, ramps up production; the earlier shipment lands, stock
spikes; the producer sees high stock, cuts production; the pipeline runs
dry while the cut is still working its way through, stock craters, and the
cycle repeats. The oscillation isn't a bug in the production formula — the
formula is executing exactly as specified. The bug is the blind spot: the
decision rule was never given the information it needed to see the
correction already coming.

**Remedy.** Feed in-flight transfers into the decision rule, not just
resting stock — the producer needs to know what's already coming before it
decides whether to send more.

## Behaviour-mode classification, plus extreme-condition tests

**Shape.** The only check on the economy is a numerical summary metric —
mean stock, total throughput, average price — with no check on the
*shape* of the trajectory over time.

**Symptom.** A purely numerical metric reports an oscillating economy and a
settled one identically whenever their averages happen to coincide. A
system swinging wildly between empty and overflowing pools, and a system
sitting quietly at equilibrium, can produce the same mean — and a metric
that only ever reports the mean cannot tell a reviewer which one they're
looking at.

**Remedy.** Classify the behaviour mode of the trajectory itself
(settling, oscillating, diverging, collapsing) as a first-class check, not
an afterthought layered on top of the numerical metric. Pair it with tests
at extreme conditions — zero starting stock, maximum starting stock, a
single actor, the full actor count — since these are where a shape
difference that a mid-range test would never trigger tends to surface.
