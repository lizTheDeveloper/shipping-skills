# Metric definition template

A template to adapt, not a dependency. The format is the free-parameter
table plus a version pinned by a test — copy the shape, not the specific
rows.

## Why this exists

A metric name is not a definition. "Ticks for 50% of nodes to be lost"
sounds precise and answers none of the questions that determine what the
number actually measures: how often is the cohort counted, what happens to
something that was lost and then rediscovered, what gets reported if half
the cohort is still alive when the run ends. Somebody decides those
questions whether or not the decision is written down — the difference is
only whether the next person who touches the metric reinvents the answer
differently and two incompatible quantities end up compared under one
name.

## The free-parameter table

Three columns: the ambiguity the metric name leaves open, what was pinned,
and why that answer rather than another one. Three worked rows, for the
"ticks to 50% loss" example above:

| Ambiguity the name leaves open | What was pinned | Why that answer |
|---|---|---|
| How often is the cohort counted — continuously, or sampled? | Census every fixed tick interval, not continuous tracking | Continuous tracking costs more than the metric's downstream consumers can use; sampling coarser than the interval other metrics already use would make this metric incomparable to them |
| What does the run report if the run ends before 50% is lost? | `null`, tagged `censored: true` — never the run's final tick treated as the event time | Reporting the final tick as if it were the loss event would silently understate every "hasn't happened yet" outcome as "happened right at the end," which biases every aggregate that averages over censored and uncensored runs together |
| What is the value for a sample with zero members in it? | `null` — never `0` | An empty arm and a perfectly *equal* arm are different findings. Reporting both as `0` collapses "there was nothing to measure" and "we measured it and found no inequality" into the same number, and a reader downstream cannot tell which one they're looking at |

Adapt the rows to your own metric; keep the property that every row names
an ambiguity nobody would think to ask about until they hit it in
production.

## The `definitionVersion` mechanism

Pin the whole table behind a version number, computed as a digest of the
normative definition text, and assert it with a test:

```python
def test_metric_definition_version_matches():
    current = hash_definition(load_definition_doc("ticks-to-50pct-loss.md"))
    assert current == PINNED_DEFINITION_VERSION, (
        "the normative definition changed without a version bump — "
        "either the doc drifted from the pinned hash by accident, "
        "or this is a real definition change and needs a new "
        "definitionVersion plus a migration note for anything that "
        "compared against the old one"
    )
```

A version bump is a deliberate, reviewable act — exactly like a golden
baseline regeneration. Nobody should be able to silently change what "ticks
to 50% loss" means and have every consumer of that metric keep reading it
as the same number.

## The two-directional test

The table and the metric registry are asserted against each other in
**both** directions, not just one:

```python
def test_every_registered_constant_has_a_table_row():
    for name in metric_registry.free_parameters("ticks-to-50pct-loss"):
        assert name in definition_table.rows, (
            f"constant {name!r} exists in the registry with no row in the "
            f"definition table — it is free and undocumented"
        )

def test_every_table_row_has_a_registered_constant():
    for name in definition_table.rows:
        assert name in metric_registry.free_parameters("ticks-to-50pct-loss"), (
            f"table row {name!r} documents a constant the registry no "
            f"longer declares — the table has drifted ahead of the code"
        )
```

A constant added to the registry and not the table fails the first test.
A row left in the table after its constant is removed from the registry
fails the second. That symmetry is what makes this the one kind of design
document that can't go stale silently — **it cannot drift from the code
without the suite going red**, in either direction.
