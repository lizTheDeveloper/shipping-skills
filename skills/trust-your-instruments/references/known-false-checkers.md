# Known false checkers

Every entry here reported confidently and none of them threw.

Append your own in the same shape: what the checker said, what was actually true, and the one detail that would have caught it.

| shape | what it reported | what was actually true | the tell |
|---|---|---|---|
| Aggregator globs a directory for `.ndjson` output | A well-formed archive, every number plausible | A second invocation had folded the first invocation's records into its own — at a different `--ticks` | The only symptom was a denominator that did not match the flag |
| Aggregator locates input by file shape, not name | A clean before/after comparison | Records were committed as CSV; the analyser read `.runs.ndjson`, found nothing historical, and silently diffed the new run against itself | No historical file existed under the name the analyser expected — the shape it found instead was the new run |
| `awk '{print $2}'` on `gh pr checks` output | Nothing green for ten straight minutes | Both required checks were green | Columns are tab-separated and the first contains spaces, so `Verify (pinned Node)` splits into three fields and `$2` is `(pinned` |
| jq `.conclusion // "not-started"` | `not-started`, twenty polls running | The job was in progress the whole time | A running job's `conclusion` is `""`, not `null` — `//` only falls through on `null` and `false`, not on an empty string |
| CI gate reads the newest workflow run | "Main is green" | The newest run was on an unrelated branch, not `origin/main` | The gate never checked which ref the run belonged to before reporting on it |
| `assertRepresentable` bounds check | Every value in range, ~3,900 tests green, the project's entire history | The guard could not detect NaN at all | Every comparison with NaN is false, so a bounds check waves it through — found by someone asking, not by a test failing |
| Metric registry, reading as 28 healthy constants | Stable, well-behaved metrics across the board | 16 of the 28 were structurally incapable of moving | Nobody had run the amplify-and-diff check against the metrics themselves — a flat line and a correctly-flat metric render identically |
