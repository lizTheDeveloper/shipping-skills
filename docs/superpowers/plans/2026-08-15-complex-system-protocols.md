# Complex-System Protocols Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add four skills and one output style to `shipping-skills`, covering the case the repo does not yet handle — software whose output is a number you then have to trust.

**Architecture:** Prose artifacts only. Four `SKILL.md` files with five reference files between them, one output style, four edits to existing skills, and a README pass. No runtime code ships. Each task is gated by an uncommitted structural checker (Task 1) that goes red before the artifact is written and green after — the prose analogue of a TDD cycle, and itself an instance of the positive-control rule these skills teach.

**Tech Stack:** Markdown with YAML frontmatter. Python 3 for the build-time checker (scratchpad only, never committed). Git.

**Spec:** `docs/superpowers/specs/2026-08-15-complex-system-protocols-design.md` — read it alongside this plan. The spec carries the content of every section; this plan carries the order, the gates and the exact figures.

---

## Global Constraints

- **Working tree:** `/Users/annhoward/src/shipping-skills-csp`, branch `complex-system-protocols`. Never edit `/Users/annhoward/src/shipping-skills` — it is the shared checkout.
- **`<scratchpad>`** in every command below means `/private/tmp/claude-501/-Users-annhoward-src-multiverse-mages/b9e888df-dbb0-42d6-8f66-b00579a49520/scratchpad`. If executing in a later session with a different scratchpad, substitute yours — the checker is disposable and belongs nowhere else.
- **Git identity:** commit as `lizTheDeveloper` / `aethrix@themultiverse.school`. Use `git -c user.name=... -c user.email=...`.
- **Never `git stash`.** The stash is repo-global. To swap a file to another revision, `git show <ref>:<path> > <path>`.
- **House style:** frontmatter is `---`, `name:`, then folded `description: >`; body opens with a single `# Title`. Prose-first, bold on the load-bearing noun. Tables only when comparing more than two things on more than one axis.
- **Every number is a measurement from a named build.** Use only figures from the Verified Figures table below. Any other figure is invented and the checker rejects it.
- **Vendor- and project-neutral in the instructions; specific in the examples.** The repo names Hetzner, Coolify, GlitchTip as working choices, not requirements — match that posture.
- **Lead each section with the failure mode, not the remedy.** Spec §11.
- **No new committed tooling, scripts or CI.** Spec §10. The Task 1 checker lives in the scratchpad and is never `git add`ed. Reference files are templates and catalogues; anything executable that ships is a skeleton the reader adapts.
- **Do not soften the cases where the source project was confidently wrong.** Those are the parts that transfer.
- **Licence:** repo is MIT. No AGPL headers — that is the source project's licence, not this one.

### Verified Figures

Every figure below was read from the Multiverse Mages repository during design. Attribute measurements to the build, and date them. Do not round, do not "clean up", do not invent neighbours.

| Figure | What it is |
|---|---|
| `40/40` vs `38/40` | `permit-then-idle` against `permissive-breadth` — the do-nothing bot beat the playing bot |
| `12/12`, median tick `707`, `50.4` nodes | `uniform-random-legal` ascension — pressing buttons uniformly |
| `8` of `10` strategies at rate exactly `0.0000` | there is no ladder to climb |
| `217.3` / `51.0` / `7.7` nodes known | `permissive-breadth` / passive / `narrow-depth` |
| `91.4%` first principal component; participation ratio `1.19`; containment `1.000`; prefix fidelity `0.943`, exact on `65/84` | strategy space is one-dimensional |
| `16` of `28` registered metrics quarantined | structurally incapable of moving |
| `~3,900` passing tests | did not notice `assertRepresentable` could not fire |
| `830` s quiet / `1154` s busy / `2400` s runner timeout; seven PRs stacked in one day | the 200-year balance gate held in the merge gate |
| `0` of `400` at twenty world years; `46` of `64` at two hundred | the win-condition gate |
| ×100 amplification: control `1867`/`4571`; research-rate `1779`/`4541`; teach-rate `1288`/`4564` (−`31%`); scribe-rate `1414`/`4407`; lifespan `1867`/`4571`; fertility `1867`/`4571` | lessons / research; last two byte-identical |
| eleven UI prototypes; four defects found | `interface-findings.md` |
| four recorded architecture deviations | "§5 was drawn before anyone tried to satisfy it" |
| `300` nodes across `70` cells, `12` enabled; `51` v1 nodes | grid scale |

---

## File Structure

| Path | Responsibility |
|---|---|
| `output-styles/caveman.md` | New artifact type for the repo. Terse-output style, genericised. |
| `skills/trust-your-instruments/SKILL.md` | Orthogonal. Checkers, guards, metrics, knobs. Usable with no simulation present. |
| `skills/trust-your-instruments/references/probe-template.sh` | Three-exit probe skeleton. |
| `skills/trust-your-instruments/references/known-false-checkers.md` | The five-in-one-night catalogue, appendable. |
| `skills/ground-a-simulation/SKILL.md` | Phase 1. What to build before any number exists. |
| `skills/ground-a-simulation/references/determinism-checklist.md` | Lint rules, manifest check, division-helper contract. |
| `skills/ground-a-simulation/references/metric-definition-template.md` | Free-parameter table + two-directional test. |
| `skills/ground-a-simulation/references/economy-flow-patterns.md` | Machinations vocabulary, four failure modes. |
| `skills/search-dont-argue/SKILL.md` | Phase 2. Finding numbers nobody can defend. |
| `skills/audit-a-simulation/SKILL.md` | Phase 3. Defending numbers that are load-bearing. |
| `skills/{version-and-claim,detect-drift,run-a-campaign,release-process}/SKILL.md` | Targeted additions, spec §8. |
| `README.md` | Four table rows, the arc, output-styles section, install block, one paragraph. |

**Task order note.** `trust-your-instruments` is written first because the other three link into it. Its own back-link to `ground-a-simulation` §3.8 will dangle until Task 3; the checker permits a `§` ref whose line names another skill in backticks, and Task 8 confirms every such ref resolves for real.

---

## Task 1: The gate, and caveman

**Files:**
- Create: `<scratchpad>/check-skills.py` — **never committed**
- Create: `output-styles/caveman.md`
- Source: `/Users/annhoward/src/multiverse_mages/.claude/output-styles/caveman.md`

**Interfaces:**
- Consumes: nothing.
- Produces: `python3 <scratchpad>/check-skills.py .` run from the worktree root. Exit `0` all green, `42` an artifact fails, `1` the probe is broken. Every later task runs this.

- [ ] **Step 1: Write the checker**

Create `<scratchpad>/check-skills.py` with exactly this content:

```python
#!/usr/bin/env python3
"""Structural gate for shipping-skills. Not committed — a build-time probe only.

Exit codes, per the repo's own third-exit rule:
  0  all checked artifacts pass
  42 at least one artifact fails a check
  1  the probe itself is broken (bad args, unreadable manifest)
"""
import os
import re
import sys

REPO = sys.argv[1] if len(sys.argv) > 1 else "."

# Artifacts the gate expects to exist. A skill is added here BEFORE it is
# written, so the gate goes red first. That red is the point.
EXPECTED_SKILLS = [
    "trust-your-instruments",
    "ground-a-simulation",
    "search-dont-argue",
    "audit-a-simulation",
]
EXPECTED_STYLES = ["caveman"]

# Positive control: these already exist on main and must keep passing.
# If the gate ever reports zero failures AND zero controls checked, it is broken.
CONTROL_SKILLS = ["detect-drift", "release-process", "version-and-claim"]

PLACEHOLDERS = re.compile(r"\bTBD\b|\bTODO\b|\bFIXME\b|\bXXX\b|lorem ipsum", re.I)

# Signature figures from the Multiverse Mages build. Any figure matching
# FIGURE_SHAPE that is not in this set is an invented number until proven.
KNOWN_FIGURES = {
    "40/40", "38/40", "12/12", "0/400", "46/64", "16/28", "65/84",
    "8/10", "3/12", "5/12", "0.0000", "91.4%", "94.3%", "1.19", "1.000",
    "0.943", "1867", "4571", "1779", "4541", "1288", "4564", "1414",
    "4407", "830", "1154", "2400", "707", "962", "1201", "1202", "217.3",
    "50.4", "50.9", "51.0", "31%", "3,900", "4,306",
}
FIGURE_SHAPE = re.compile(r"\b\d+/\d+\b|\b\d+\.\d+%|\b\d+\.\d{3,4}\b")

def _self_test():
    """Positive control for the figure guard itself.

    The three skill-level controls contain no figures at all, so without this
    the strongest check in the probe would never be observed either accepting
    or rejecting. A guard only ever seen rejecting nothing is not a guard.
    """
    good = "the null bot scored 40/40 against 38/40"
    bad = "the null bot scored 39/41 against 12/97"
    if [f for f in FIGURE_SHAPE.findall(good) if f not in KNOWN_FIGURES]:
        return "figure guard rejected a known-good figure"
    if not [f for f in FIGURE_SHAPE.findall(bad) if f not in KNOWN_FIGURES]:
        return "figure guard accepted an invented figure"
    return None


_err = _self_test()
if _err:
    print(f"PROBE BROKEN: {_err}", file=sys.stderr)
    sys.exit(1)

failures = []
controls_checked = 0


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def split_frontmatter(text, path):
    if not text.startswith("---\n"):
        failures.append(f"{path}: no YAML frontmatter (must start with ---)")
        return None, text
    end = text.find("\n---\n", 4)
    if end == -1:
        failures.append(f"{path}: frontmatter never closes")
        return None, text
    return text[4:end], text[end + 5:]


def check_common(path, expect_name, folded_desc, check_figures=True, require_h1=True):
    if not os.path.exists(path):
        failures.append(f"{path}: does not exist")
        return False
    text = read(path)
    fm, body = split_frontmatter(text, path)
    if fm is None:
        return False

    m = re.search(r"^name:\s*(\S+)", fm, re.M)
    if not m:
        failures.append(f"{path}: frontmatter has no name:")
    elif m.group(1) != expect_name:
        failures.append(f"{path}: name is {m.group(1)!r}, expected {expect_name!r}")

    if not re.search(r"^description:", fm, re.M):
        failures.append(f"{path}: frontmatter has no description:")
    elif folded_desc and not re.search(r"^description:\s*>", fm, re.M):
        failures.append(f"{path}: description must use folded '>' (house style)")

    # Skills are documents and open with an H1. An output style's body is a
    # system prompt, not a document — it opens with the operative instruction,
    # and an H1 there is padding. Different artifact, different rule.
    if require_h1 and not re.search(r"^# \S", body, re.M):
        failures.append(f"{path}: no H1 title in body")

    for hit in PLACEHOLDERS.findall(text):
        failures.append(f"{path}: placeholder {hit!r}")

    # Intra-file section refs must resolve to a heading in the same file,
    # unless the ref names another artifact on the same line.
    headings = set(re.findall(r"^#{2,4}\s+(\d+(?:\.\d+)?)", body, re.M))
    for line in body.splitlines():
        for ref in re.findall(r"§(\d+\.\d+)", line):
            names_other = re.search(r"`[a-z-]+`\s*§|\bin\s+`", line)
            if ref not in headings and not names_other:
                failures.append(f"{path}: §{ref} resolves to nothing here")

    if check_figures:
        for fig in FIGURE_SHAPE.findall(text):
            if fig not in KNOWN_FIGURES:
                failures.append(
                    f"{path}: unverified figure {fig!r} — check it against the plan's "
                    f"Verified Figures table; do NOT widen KNOWN_FIGURES to pass")

    return True


for name in EXPECTED_SKILLS:
    check_common(os.path.join(REPO, "skills", name, "SKILL.md"), name, True)

for name in EXPECTED_STYLES:
    p = os.path.join(REPO, "output-styles", f"{name}.md")
    if check_common(p, name.capitalize(), False, require_h1=False):
        t = read(p)
        for bad in ("multiverse", "docs/design/vision.md", "mages"):
            if bad.lower() in t.lower():
                failures.append(f"{p}: project-specific reference {bad!r} must be genericised")

for name in CONTROL_SKILLS:
    p = os.path.join(REPO, "skills", name, "SKILL.md")
    if not os.path.exists(p):
        print(f"PROBE BROKEN: control skill missing: {p}", file=sys.stderr)
        sys.exit(1)
    before = len(failures)
    check_common(p, name, True, check_figures=False)
    controls_checked += 1
    if len(failures) != before:
        print(f"PROBE BROKEN: positive control {name} failed:", file=sys.stderr)
        for f in failures[before:]:
            print(f"  {f}", file=sys.stderr)
        sys.exit(1)

if controls_checked == 0:
    print("PROBE BROKEN: no positive controls ran", file=sys.stderr)
    sys.exit(1)

if failures:
    print(f"FAIL ({len(failures)}), controls green: {controls_checked}")
    for f in failures:
        print(f"  {f}")
    sys.exit(42)

print(f"PASS — {len(EXPECTED_SKILLS)} skills, {len(EXPECTED_STYLES)} styles, "
      f"{controls_checked} positive controls")
sys.exit(0)
```

- [ ] **Step 2: Run it — confirm it is red, and confirm the red is real**

```bash
cd /Users/annhoward/src/shipping-skills-csp
python3 <scratchpad>/check-skills.py . ; echo "EXIT=$?"
```

Expected: `EXIT=42`, five `does not exist` lines, and `controls green: 3`.

The `controls green: 3` is not decoration. A gate that reports failure while its positive controls never ran is the failure mode this whole repo warns about. If that number is `0`, stop — the probe is broken, not the tree.

- [ ] **Step 3: Confirm the third exit works**

```bash
mkdir -p /tmp/emptyrepo && python3 <scratchpad>/check-skills.py /tmp/emptyrepo ; echo "EXIT=$?"
```

Expected: `EXIT=1` and `PROBE BROKEN: control skill missing`. **Not** `42`. If a missing-control tree reports `42`, the probe is folding "broken" into "no" and must be fixed before any other task runs.

- [ ] **Step 4: Copy caveman across**

```bash
mkdir -p /Users/annhoward/src/shipping-skills-csp/output-styles
cp /Users/annhoward/src/multiverse_mages/.claude/output-styles/caveman.md \
   /Users/annhoward/src/shipping-skills-csp/output-styles/caveman.md
```

- [ ] **Step 5: Genericise the three project-specific references**

Three edits and no more. Spec §7: *do not rewrite it — the terseness is the point and an edit pass will pad it.*

In the "Point, do not retell" section, replace the repo-prose example:

```
- Repo prose → name the doc and section: `docs/design/vision.md` §7. Do not summarize a doc
```

with:

```
- Repo prose → name the doc and section: `docs/architecture.md` §7. Do not summarize a doc
```

In the same section, replace the code-comment path example `spec.md:158` only if it names a project-specific file — it does not, so leave it. Then scan for any remaining occurrence:

```bash
grep -in "multiverse\|mages\|vision.md" output-styles/caveman.md
```

Expected: no output. If a line remains, replace the project-specific path with a generic one (`docs/architecture.md`, `spec.md`) and leave the surrounding prose untouched.

- [ ] **Step 6: Run the gate**

```bash
python3 <scratchpad>/check-skills.py . ; echo "EXIT=$?"
```

Expected: `EXIT=42` with **four** remaining `does not exist` lines (the four skills) and **no** line mentioning `output-styles/caveman.md`. Caveman is now green; the skills are not yet written.

Note the checker exempts output styles from the H1-title rule. Skills are documents and open with an H1; an output style's body is a system prompt that opens with its operative instruction, and an H1 there would be the padding this task is forbidden to add.

- [ ] **Step 7: Commit**

```bash
cd /Users/annhoward/src/shipping-skills-csp
git add output-styles/caveman.md
git -c user.name=lizTheDeveloper -c user.email=aethrix@themultiverse.school \
  commit -m "Add caveman output style

The repo's first output style. Terse output that cites a fact's location
instead of making a second copy that can rot — the same rule the rest of
these skills apply to infrastructure, applied to prose.

Copied from a working project checkout with project-specific paths
genericised. Otherwise unmodified: the terseness is the point.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: `trust-your-instruments`

**Spec:** §6, all of it. Read it before writing.

**Files:**
- Create: `skills/trust-your-instruments/SKILL.md`
- Create: `skills/trust-your-instruments/references/probe-template.sh`
- Create: `skills/trust-your-instruments/references/known-false-checkers.md`

**Interfaces:**
- Consumes: the Task 1 gate.
- Produces: seven `## N.N` headings — `6.1` … `6.7` are spec numbering; in the skill itself use plain `##` headings with the titles below, since a standalone skill has no parent document to number against. Later tasks link to it **by name and heading title**, never by section number:
  - `## When a check reports the negative case, confirm the check works`
  - `## Positive controls`
  - `## The third exit`
  - `## Locate input by name, never by shape`
  - `## A guard that cannot fire`
  - `## A metric that cannot move`
  - `## Prove the knob moves the system`

- [ ] **Step 1: Confirm the gate is red for this artifact**

```bash
python3 <scratchpad>/check-skills.py . 2>&1 | grep trust-your-instruments
```

Expected: `./skills/trust-your-instruments/SKILL.md: does not exist`

- [ ] **Step 2: Write the frontmatter and title**

Create `skills/trust-your-instruments/SKILL.md` opening with exactly:

```markdown
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

A check that answers a question about the wrong input is worse than no check, because it answers confidently and nothing throws.
```

- [ ] **Step 3: Write the seven sections**

Follow spec §6.1–6.7 in order, using the heading titles from the Interfaces block above. Each section leads with the failure mode.

Non-negotiable content, because it is what makes each section land:

- **The third exit** — `0` open, `42` shut, `1` the probe is broken. State that folding "broken" into "no" is the default failure because both produce a non-zero exit.
- **Locate input by name** — all five catalogue entries from spec §6.4, each with its symptom. The glob-aggregator entry must keep *"the only symptom was a denominator that did not match the flag"*; the `awk` entry must keep that `Verify (pinned Node)` splits into three fields so `$2` is `(pinned`; the jq entry must keep that `//` falls through only on `null` and `false`, not `""`.
- **A guard that cannot fire** — `assertRepresentable`, `~3,900` passing tests, every comparison with NaN is false, found by someone asking rather than by a test. Link forward: *"the remedy is a property test — see `ground-a-simulation`."*
- **A metric that cannot move** — `16` of `28` quarantined.
- **Prove the knob moves the system** — the ×100 table verbatim from the Verified Figures row, as a markdown table with a `verdict` column. Then the detail that earns it a section: **a static consumption check names a consumer for both inert values, and passes.** Close on: *no gate I used could have seen it.* Then name the connection — ×0 and ×100 are the degenerate-ends-as-controls rule applied to wiring rather than tuning; ablation and amplification are one instrument pointed two directions. Reference `search-dont-argue` by name.

- [ ] **Step 4: Write `references/probe-template.sh`**

```bash
#!/usr/bin/env bash
# Three-exit probe skeleton.
#   0  the condition holds (open)
#   42 the condition does not hold (shut)
#   1  the probe could not answer (broken)
#
# The third exit is the point. Without it, "I could not tell" is
# indistinguishable from "no", because both are non-zero.
set -uo pipefail

broken() { echo "PROBE BROKEN: $*" >&2; exit 1; }

# 1. Establish the probe can work at all, before trusting any answer.
command -v jq >/dev/null 2>&1 || broken "jq not on PATH"
[[ -n "${TARGET_REF:-}" ]]    || broken "TARGET_REF unset"

# 2. Locate input BY NAME. Never by glob, never by readdir order,
#    never by 'the file that looks like the right shape'.
INPUT="records/${TARGET_REF}.ndjson"
[[ -f "$INPUT" ]] || broken "no record for ${TARGET_REF} at ${INPUT}"

# 3. Positive control: an input the probe MUST accept. If this fails,
#    the probe is wrong, not the tree.
CONTROL="records/known-good.ndjson"
[[ -f "$CONTROL" ]] || broken "positive control missing: ${CONTROL}"
jq -e 'has("result")' "$CONTROL" >/dev/null 2>&1 \
  || broken "positive control did not parse — probe cannot read this format"

# 4. Only now is a negative answer believable.
if jq -e '.result == "ok"' "$INPUT" >/dev/null 2>&1; then
  echo "OPEN: ${TARGET_REF}"
  exit 0
fi

echo "SHUT: ${TARGET_REF}"
exit 42
```

- [ ] **Step 5: Write `references/known-false-checkers.md`**

A catalogue with one row per shape, structured so a reader appends their own. Columns: **shape**, **what it reported**, **what was actually true**, **the tell**. Seed it with the five from spec §6.4 plus the guard-that-cannot-fire and the metric-that-cannot-move. Open with one line: *"Every entry here reported confidently and none of them threw."*

- [ ] **Step 6: Run the gate**

```bash
python3 <scratchpad>/check-skills.py . ; echo "EXIT=$?"
```

Expected: `EXIT=42`, three remaining `does not exist` lines, **none** of them `trust-your-instruments`. If a figure is rejected, do not add it to `KNOWN_FIGURES` — check it against the Verified Figures table first. The checker is right more often than the draft.

- [ ] **Step 7: Commit**

```bash
git add skills/trust-your-instruments/
git -c user.name=lizTheDeveloper -c user.email=aethrix@themultiverse.school \
  commit -m "Add trust-your-instruments

A checker that answers about the wrong input reports confidently and never
throws. Five shapes from one night, a guard that could not fire against
~3,900 green tests, metrics that cannot move, and the dual nobody runs:
amplify every authored magnitude and see whether the run moves.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: `ground-a-simulation`

**Spec:** §3, all of it, plus §2 and §2.1 for the framing it must carry.

**Files:**
- Create: `skills/ground-a-simulation/SKILL.md`
- Create: `skills/ground-a-simulation/references/determinism-checklist.md`
- Create: `skills/ground-a-simulation/references/metric-definition-template.md`
- Create: `skills/ground-a-simulation/references/economy-flow-patterns.md`

**Interfaces:**
- Consumes: Task 1 gate; `trust-your-instruments` exists and may be linked by name.
- Produces: the phase-1 anchor. `audit-a-simulation` (Task 5) links back to its heading `## What you can pin before you know any numbers`, and `trust-your-instruments` links to `## Property tests on the arithmetic`.

- [ ] **Step 1: Confirm the gate is red for this artifact**

```bash
python3 <scratchpad>/check-skills.py . 2>&1 | grep ground-a-simulation
```

Expected: `./skills/ground-a-simulation/SKILL.md: does not exist`

- [ ] **Step 2: Write frontmatter and the opening**

```markdown
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
```

- [ ] **Step 3: Write the twelve sections, in spec order**

Spec §3.1 through §3.12 map to plain `##` headings. **Order is load-bearing** — §11 of the spec says if a draft reads as "do all of this before writing anything", the framing sections are too late and too quiet. So:

1. `## The retrofit test`
2. `## What you can pin before you know any numbers` — the identity/value table, both failure modes
3. `## Rigor is staged — what this does not ask of your merge gate` — two axes; pre-1.0 the merge gate is cheap-and-deterministic only; a broken contract pre-1.0 is a release-note entry, not a merge failure; what does *not* relax is TDD at unit level, determinism, arithmetic property tests
4. `## Prototype the subsystem to find the integration test` — the prototype's output is the integration test and often the contract; the prototype's code is throwaway and should be labelled so; the four-status vocabulary (`open` / `defect` / `resolved` / `blocked`), with `blocked` meaning *cannot be settled until a balance number exists*; the recorded-session-becomes-a-test transition; and *"a finding that lives only in a pull-request description is a finding that evaporates when the branch merges"*
5. `## Determinism as a precondition`
6. `## Stream-split randomness, with a permanent ID registry`
7. `## Baselines that cannot re-bless themselves`
8. `## Property tests on the arithmetic` — the Zeno stall, and *a property test is the positive control for a guard*
9. `## The null before the first real one` — `40/40` vs `38/40`; `12/12` at median tick `707`; `8` of `10` at exactly `0.0000`
10. `## Pin your metric definitions, with a version` — a metric name is not a definition; the free-parameter table; `definitionVersion`; the two-directional test, whose property is that **the document cannot go stale without the suite going red**
11. `## One vocabulary`
12. `## If it has an economy, model the flows first`

- [ ] **Step 4: Write `references/determinism-checklist.md`**

Copy-pasteable enforcement, framed as "adapt these, they are not a dependency":
- ESLint `no-restricted-globals` / `no-restricted-properties` for `Math.random`, `Date.now`, `new Date`, `performance.now`, `Intl`
- a float-literal ban scoped to the rules path
- a package-manifest check asserting zero runtime dependencies
- the shared division helper contract: one function, rounding toward negative infinity, defined for negative operands, with the property test that pins it
- the stream-ID registry test: append-only, no reuse, and a failure message that names both colliding IDs **and** states that committed baselines are invalidated

- [ ] **Step 5: Write `references/metric-definition-template.md`**

The free-parameter table format: three columns — *ambiguity the metric name leaves open* / *what was pinned* / *why that answer*. Then the `definitionVersion` mechanism, and the two-directional test: a constant in the registry but not the table fails, and a row in the table for a constant the registry does not declare fails. State the property this buys: **the document cannot go stale without the suite going red.**

Seed with three worked rows drawn from spec §3.10's source material — census interval; what a censored run reports; what an empty sample's inequality coefficient is (`null`, because an empty arm and an equal arm are different findings).

- [ ] **Step 6: Write `references/economy-flow-patterns.md`**

The Machinations vocabulary in brief, then the four failure modes from spec §3.12, each as **shape → symptom → remedy**:
- source/sink power matching — diagnostic is *unspent pools*, never aggregate production
- converter engine deadlock — remedy is a weak static engine
- producer decision rule ignoring in-flight transfers — canonical oscillation generator
- behaviour-mode classification plus extreme-condition tests — because a numerical metric reports an oscillating run and a settled run identically

Cite Dormans (2012), *Engineering Emergence*, ILLC DS-2012-12, CC BY-NC 3.0 NL, as the source of the vocabulary.

- [ ] **Step 7: Run the gate**

```bash
python3 <scratchpad>/check-skills.py . ; echo "EXIT=$?"
```

Expected: `EXIT=42`, two remaining `does not exist` lines, neither `ground-a-simulation`.

- [ ] **Step 8: Commit**

```bash
git add skills/ground-a-simulation/
git -c user.name=lizTheDeveloper -c user.email=aethrix@themultiverse.school \
  commit -m "Add ground-a-simulation

Phase 1: what to build before any number exists, chosen by retrofit cost.
Includes the two things that keep it from reading as ceremony — rigor is
staged on two axes, and prototyping a whole subsystem is how you find out
what the integration test should assert.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: `search-dont-argue`

**Spec:** §4, all of it.

**Files:**
- Create: `skills/search-dont-argue/SKILL.md`

**Interfaces:**
- Consumes: Task 1 gate; links by name to `trust-your-instruments` (`## A metric that cannot move`).
- Produces: the phase-2 anchor. `trust-your-instruments` §"Prove the knob moves the system" links back to its `## Both degenerate ends as controls`.

- [ ] **Step 1: Confirm the gate is red for this artifact**

```bash
python3 <scratchpad>/check-skills.py . 2>&1 | grep search-dont-argue
```

Expected: `./skills/search-dont-argue/SKILL.md: does not exist`

- [ ] **Step 2: Write frontmatter and the opening**

```markdown
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

If a number has to be figured out, do not figure it out. **Search it. The deliverable is the curve, not the value.**
```

- [ ] **Step 3: Write the eight sections**

Spec §4.1–4.8 as plain `##` headings:

1. `## The rule`
2. `## Both degenerate ends as controls`
3. `## A flat curve is a real finding` — say early and plainly that this is a *success*, because otherwise it reads as a failed experiment and gets dropped; that is how a guessed scalar in a flat region becomes indistinguishable from a mechanic that does nothing
4. `## Prerequisite: the metric must be able to move` — stage zero, `16` of `28`, link to `trust-your-instruments`
5. `## Common random numbers, and the round-robin trap` — seeds derived from `(rootSeed, sweepId, cellIndex, replicateIndex)`; round-robin arm assignment deals **disjoint** replicate indexes, so arms never play the same world and the comparison carries a seed-set difference; a candidate-versus-null ladder is more sensitive to this than a tuner is
6. `## Never cache the null bar`
7. `## Tuning and variety are different searches` — shared constant for tuning, per-universe factor for variety; a shared cost surface can only reweight terms that already differ between universes
8. `## An argument survives the evidence` — closing note

- [ ] **Step 4: Run the gate**

```bash
python3 <scratchpad>/check-skills.py . ; echo "EXIT=$?"
```

Expected: `EXIT=42`, one remaining `does not exist` line: `audit-a-simulation`.

- [ ] **Step 5: Commit**

```bash
git add skills/search-dont-argue/
git -c user.name=lizTheDeveloper -c user.email=aethrix@themultiverse.school \
  commit -m "Add search-dont-argue

Phase 2: the deliverable is the curve, not the value. Both degenerate ends
as controls, a flat curve named as a real finding, and the round-robin trap
that makes an arm comparison compare seeds instead of arms.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: `audit-a-simulation`

**Spec:** §5, all of it.

**Files:**
- Create: `skills/audit-a-simulation/SKILL.md`

**Interfaces:**
- Consumes: Task 1 gate; links by name to `ground-a-simulation` and `trust-your-instruments`.
- Produces: the phase-3 anchor. Task 6 points `run-a-campaign` at its `## Has the strategy space collapsed?` heading, and `release-process` at `## Split your gates by cost`.

- [ ] **Step 1: Confirm the gate is red for this artifact**

```bash
python3 <scratchpad>/check-skills.py . 2>&1 | grep audit-a-simulation
```

Expected: `./skills/audit-a-simulation/SKILL.md: does not exist`

- [ ] **Step 2: Write frontmatter and the opening**

```markdown
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

**Phase 3 of three.** The numbers exist and something is now standing on them. Grounding the system is `ground-a-simulation`; finding numbers nobody can defend is `search-dont-argue`.

The characteristic failure here is not a crash. It is a plausible number.
```

- [ ] **Step 3: Write the seven sections**

Spec §5.1–5.7 as plain `##` headings:

1. `## First: which foundations do you actually have?` — determinism, stream splitting, identity baselines, pinned metric definitions, a null. Returns a **stop-and-retrofit** verdict where one is missing, not a patch. Say why: it follows from the retrofit test, and stating it as a verdict is what stops the rest of the document being read as a workaround.
2. `## The silent zero` — both routes. Include the pipeline as an indented block:

```
a lookup misses
  -> undefined enters arithmetic
  -> NaN comes out
  -> it is written to an integer column
  -> the typed array coerces NaN to 0
  -> the mechanic contributes nothing, forever
```

   Then the second route with no NaN at all — division toward negative infinity, a small per-tick increment flooring to exactly zero, the **Zeno stall**, arithmetic working perfectly. Close on: whoever sees the intermediate value calls it NaN contamination, whoever sees the stored value calls it a quantity that fell to zero — same defect, two complaints.
3. `## Why the unit suite is structurally blind to it` — *a unit test builds its own fixture, so its lookups always hit*. The remedy is a different category of test, not more of the same. Link back to `ground-a-simulation`'s prototyping section.
4. `## Absence claims require execution` — the branch evaluated **zero** times.
5. `## Has the strategy space collapsed?` — runnable recipe: PCA over runs × features, participation ratio, pairwise containment. `91.4%`, `1.19`, `1.000`. *Strategies do not pick different subsets; they stop at different points along one queue.*
6. `## Split your gates by cost` — `830` s / `1154` s / `2400` s, seven PRs stacked in one day, now parallel and not required to merge.
7. `## A background loop outlives the reasoning that started it` — `pgrep` first; when you write a prohibition, check whether the prohibited thing is running; never an unattended both-checks-green drainer, because a green check is a statement about the base it ran on.

- [ ] **Step 4: Run the gate — expect the first full green**

```bash
python3 <scratchpad>/check-skills.py . ; echo "EXIT=$?"
```

Expected: `EXIT=0` and `PASS — 4 skills, 1 styles, 3 positive controls`.

This is the first time the gate goes green. Confirm the count line says `4 skills` — a green with a smaller count means the manifest was edited rather than the tree fixed.

- [ ] **Step 5: Commit**

```bash
git add skills/audit-a-simulation/
git -c user.name=lizTheDeveloper -c user.email=aethrix@themultiverse.school \
  commit -m "Add audit-a-simulation

Phase 3: the characteristic failure is a plausible number. The silent zero
and why the unit suite cannot see it, absence claims that need execution,
measuring whether the strategy space collapsed, and splitting gates by cost.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Additions to four existing skills

**Spec:** §8. Additions only — do not restructure the host skills.

**Files:**
- Modify: `skills/version-and-claim/SKILL.md`
- Modify: `skills/detect-drift/SKILL.md`
- Modify: `skills/run-a-campaign/SKILL.md`
- Modify: `skills/release-process/SKILL.md`

**Interfaces:**
- Consumes: Tasks 2–5 — every skill referenced by name now exists.
- Produces: nothing later tasks depend on except the README's accuracy.

- [ ] **Step 1: Read each host skill before editing it**

```bash
for f in version-and-claim detect-drift run-a-campaign release-process; do
  echo "===== $f ====="; cat "skills/$f/SKILL.md"
done
```

Match each file's existing heading depth and voice. An addition that reads as bolted on is worse than none.

- [ ] **Step 2: `version-and-claim` — the claim's third clause, and parity**

Add to the section on release claims: a claim needs the disproving measurement **and whether that measurement is actually collected yet**. The skill already has the first two; the third is what separates a claim from an intention.

Then a short subsection on MINOR parity as a worked pattern: even = balance-validated, odd = in flight; every capability ships twice, landing on an odd MINOR and being *promoted* to the next even one when its baselines are green; the even release is **earned, not scheduled**; the gate is enforced in CI, not intended, because a version scheme that relies on someone remembering lies within a month; and parity is **undefined** below the version where the harness first exists — said out loud rather than pretended.

- [ ] **Step 3: `detect-drift` — a document is not a ref, and index by kind**

Add: **a document is not a ref for the code it describes.** Date every measurement and name the ref it was taken on; an undated measurement in the present tense reads as current for as long as it survives.

Worked case: a project audit asserted a figure in the present tense and tagged it `[executed]`, while a test file on the same commit carried the same figure under *"this is a historical record, not the current measurement"*. Two documents on the main branch contradicting each other, the misleading one was the one people read, and it cost two agents a full investigation each.

Then: **index a docs directory by kind** — *authoritative* (a decision; if code disagrees, the code is wrong or the doc needs amending on purpose), *measured* (a record of something observed; it ages, it does not get rewritten), *deferred* (decided early for a release that has not arrived). Two audits were commissioned in that project that re-derived work already sitting in the directory, because it was invisible.

- [ ] **Step 4: `run-a-campaign` — measure the space before filling it**

Add a short passage: before committing a campaign to filling a space, measure whether the space has dimensions. Point at `audit-a-simulation`, heading `## Has the strategy space collapsed?`. Note that the source project's content campaign was aimed at a space measured afterwards at one effective dimension — one afternoon of measurement against months of planned work.

- [ ] **Step 5: `release-process` — gate weight is staged**

Add: **gate weight is staged.** Pre-1.0 the per-merge gate carries only cheap deterministic checks; expensive validation runs parallel and non-blocking, or per-release. Pre-1.0, a broken contract is a named release-note entry, not a merge failure. Point at `audit-a-simulation`, heading `## Split your gates by cost`, and carry the concrete cost of getting it wrong: a validation gate of `830`–`1154` s against a `2400` s runner timeout stacked seven unrelated pull requests in a single day.

- [ ] **Step 6: Run the gate**

```bash
python3 <scratchpad>/check-skills.py . ; echo "EXIT=$?"
```

Expected: `EXIT=0`. The three positive controls are among the files just edited, so a `PROBE BROKEN` here means an edit broke frontmatter or house style — fix the file, not the checker.

- [ ] **Step 7: Commit**

```bash
git add skills/version-and-claim/ skills/detect-drift/ skills/run-a-campaign/ skills/release-process/
git -c user.name=lizTheDeveloper -c user.email=aethrix@themultiverse.school \
  commit -m "Four existing skills pick up what the new ones imply

version-and-claim: a claim needs the disproving measurement AND whether it
is collected yet; MINOR parity as a worked pattern.
detect-drift: a document is not a ref for the code it describes; index docs
by kind.
run-a-campaign: measure whether the space has dimensions before filling it.
release-process: gate weight is staged, and pre-1.0 the merge gate is light.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: README

**Spec:** §9.

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add four rows to the skills table**

Append, matching the existing two-column format and voice:

```markdown
| **ground-a-simulation** | You are starting something whose output is a number you will have to trust. What to build before the first measurement, chosen by retrofit cost — and what *not* to put on a pre-1.0 merge gate. |
| **search-dont-argue** | A design decision has become a number nobody can defend. The deliverable is the curve, not the value. |
| **audit-a-simulation** | The numbers exist and something is standing on them. Silent zeros, collapsed strategy spaces, gates that stack PRs. |
| **trust-your-instruments** | A check reported something — especially something negative — and you are about to act on it. Positive controls, the third exit, and the knob that turned out to be inert. |
```

- [ ] **Step 2: Add the three-phase arc under the table**

```markdown
### The three phases

The three simulation skills are one arc, and most projects sit in the middle for years:

| | |
|---|---|
| **ground-a-simulation** | No numbers exist yet. Build only what needs none. |
| **search-dont-argue** | The numbers are unknown and must be found. The longest phase. |
| **audit-a-simulation** | Numbers exist and are load-bearing. Defend them. |

The reason it is three and not two: **you cannot commit a baseline before you know what the numbers should be.** An *identity* baseline — same input, byte-identical output — needs no known-correct values and can land on day one. A *value* baseline — this rate falls in this band — is a claim about the design and cannot exist until the design has been searched. Conflating them makes teams either skip baselines entirely and lose reproducibility permanently, or commit guesses as thresholds and spend a year re-blessing them.

**trust-your-instruments** runs across all three, and works on its own in a repo with no simulation in it at all.
```

- [ ] **Step 3: Add the output-styles section**

Place after the skills table, before Install:

```markdown
## Output styles

| Style | What it does |
|---|---|
| **caveman** | Says it in the fewest words that lose no fact. Points at files instead of retelling them. |

Caveman is the same rule the rest of this repo applies to infrastructure, applied to prose: **do not make a second copy of a fact that can rot.** Cite the file and line, name the doc and section, and keep only what lives nowhere else. Terse is not vague — dropping a number, a caveat or a path is a bug; dropping the sentence that introduces them is the point.

It is the style the worked examples in these skills were written under.
```

- [ ] **Step 4: Update the install block**

Replace the existing `cp -r` line so both artifact types are installed:

```bash
git clone https://github.com/lizTheDeveloper/shipping-skills.git
cp -r shipping-skills/skills/*         ~/.claude/skills/
cp -r shipping-skills/output-styles/*  ~/.claude/output-styles/
```

- [ ] **Step 5: Extend "the problem they solve"**

Add one paragraph after the existing bullet list:

```markdown
There is a second version of the problem, for anyone whose software produces a *number* rather than a page: a green suite, a clean deploy and a truthful changelog are all compatible with a model that has been computing zero for a year. Nothing throws, nothing is corrupt, and the result reads as a finding rather than a bug. The last four skills are for that case.
```

- [ ] **Step 6: Verify the README claims match the tree**

```bash
grep -c "^| \*\*" README.md
ls skills/ output-styles/
```

Every skill named in the table must exist as a directory, and every directory must appear in the table. This is the README's own drift check — the repo ships a skill about exactly this failure.

- [ ] **Step 7: Commit**

```bash
git add README.md
git -c user.name=lizTheDeveloper -c user.email=aethrix@themultiverse.school \
  commit -m "README: four new skills, the three-phase arc, and output styles

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: Cross-link integrity, and the PR

**Files:** none created. Verification and one PR.

- [ ] **Step 1: Every named cross-reference resolves**

The skills link to each other **by name and heading title**, not by number. Confirm each target heading exists verbatim:

```bash
cd /Users/annhoward/src/shipping-skills-csp
grep -rhoE '`(ground-a-simulation|search-dont-argue|audit-a-simulation|trust-your-instruments)`' skills/ | sort | uniq -c
grep -rn '^## ' skills/ground-a-simulation/SKILL.md skills/search-dont-argue/SKILL.md \
                skills/audit-a-simulation/SKILL.md skills/trust-your-instruments/SKILL.md
```

Read the two lists against each other. Any heading title quoted in one skill that does not appear in its target's heading list is a dangling link — fix the quoting side, not the heading.

- [ ] **Step 2: Every figure traces to the Verified Figures table**

```bash
grep -rhoE '\b[0-9]+/[0-9]+\b|\b[0-9]+\.[0-9]+%' skills/ | sort -u
```

Compare against Global Constraints. A figure here that is not there was invented during drafting — remove it or replace it with the real one. Do not widen `KNOWN_FIGURES` to make this pass.

- [ ] **Step 3: Full gate, one last time**

```bash
python3 <scratchpad>/check-skills.py . ; echo "EXIT=$?"
```

Expected: `EXIT=0`, `PASS — 4 skills, 1 styles, 3 positive controls`.

- [ ] **Step 4: Confirm nothing from the scratchpad was committed**

```bash
git log --stat --oneline complex-system-protocols ^main | grep -i "check-skills\|scratchpad\|\.superpowers" && echo "LEAK" || echo "clean"
```

Expected: `clean`. Spec §10 forbids new committed tooling. `.superpowers/` (the SDD workspace) is gitignored as of Task 1 and must never appear either.

- [ ] **Step 5: Push and open the PR**

```bash
git push -u origin complex-system-protocols
gh pr create --title "Complex-system protocols: four skills, and caveman" --body "$(cat <<'BODY'
Adds the case this repo did not cover: software whose output is a number you
then have to trust. A green suite, a clean deploy and a truthful changelog are
all compatible with a model that has been computing zero for a year.

**New skills**

- `ground-a-simulation` — phase 1. What to build before any number exists,
  chosen by retrofit cost. Explicitly says what *not* to put on a pre-1.0 merge
  gate, and licenses prototyping a whole subsystem to find out what the
  integration test should assert.
- `search-dont-argue` — phase 2, and the phase most projects live in. The
  deliverable is the curve, not the value.
- `audit-a-simulation` — phase 3. Silent zeros, collapsed strategy spaces,
  absence claims that need execution, gates that stack PRs.
- `trust-your-instruments` — orthogonal, and useful in a repo with no
  simulation in it. Positive controls, the third exit, guards that cannot fire,
  metrics that cannot move, and knobs that turn out to be inert.

**New artifact type:** `output-styles/`, with `caveman`.

**Existing skills** pick up four additions that follow from the above:
`version-and-claim`, `detect-drift`, `run-a-campaign`, `release-process`.

Every figure is a measurement from a named build, attributed and dated. The
design doc is at `docs/superpowers/specs/2026-08-15-complex-system-protocols-design.md`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
BODY
)"
```

---

## Self-Review

**Spec coverage.** §2 → Task 7 Step 2 and Task 3 Step 3 item 2. §2.1 → Task 3 Step 3 item 3, Task 6 Step 5. §3 (all twelve) → Task 3. §4 → Task 4. §5 → Task 5. §6 → Task 2. §7 → Task 1. §8 → Task 6, all four rows. §9 → Task 7, all five points. §10 → Task 1 (scratchpad only) and Task 8 Step 4 (leak check). §11 → Global Constraints and the per-task content notes. §12 → the File Structure table. No gaps.

**Placeholders.** None. Every code step carries its content; every prose step names its spec section and its non-negotiable figures.

**Consistency.** Skills cross-reference by **name and heading title**, never by section number — spec numbering (§3.4) is a property of the design doc, not of the published skills, and a plan that told executors to write `§3.4` into a standalone skill would ship dangling refs. The checker enforces this: a `§N.N` ref only passes if its line also names another artifact in backticks. Heading titles are fixed in each task's Interfaces block so producer and consumer agree.

**One known temporary state:** Task 2 writes `trust-your-instruments`, which links forward to `ground-a-simulation` before Task 3 creates it. That link is by name, so the checker permits it, and Task 8 Step 1 confirms it resolves for real.
