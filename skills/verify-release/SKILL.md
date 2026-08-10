---
name: verify-release
description: >
  Use before promoting a release, or when the user needs to check that changes
  actually work rather than that tests pass. Produces a human-walkable test plan
  against a preview URL, covering what changed plus likely side-effects. Use when
  the user says "I think it works", when reviewing agent-generated changes at
  volume, or when a release broke something nobody noticed.
---

# Verify a Release

Automated tests prove **the code does what the code says**. A test plan proves **the release does what you claimed**. They are different questions and the second one is the one that catches a bad release.

This matters more with agents: the volume of change exceeds what anyone will read, so verification has to happen at the level of behaviour, not diff.

## Produce a plan a human will actually walk

Write a numbered list of concrete actions against the **preview URL** for the release branch:

- What to click or type — literally, including the input values
- What they should see — specifically, not "it works"
- Whether a failure here **blocks the release** or is worth noting

Rules that decide whether it gets used:

- **Short enough that they will do it.** A 40-step plan is not walked; it is skimmed and signed off. Ten good steps beat forty thorough ones.
- **Cover what changed** — every behaviour in the release claims.
- **Cover likely side-effects** — the things most plausibly broken *by* those changes, which is where regressions actually live. State why each is included.
- **Include one path that should still work and has nothing to do with this release.** Login, or whatever the core flow is. This is the cheapest possible regression net.

## Format

```markdown
## Release 2.4.0 — test plan
Preview: https://preview-abc.example.com

### Blocking
1. Log in as an existing user → lands on dashboard, no console errors
2. Create an item, refresh → item persists with the same title
3. [changed] Export a report → CSV downloads, opens, has a header row

### Non-blocking
4. [changed] Empty state copy reads correctly with zero items
5. [side-effect] Existing saved filters still apply after the schema change
```

Mark `[changed]` and `[side-effect]` so the walker knows which steps are the point and which are the net.

## Put the plan in the pull request

The test plan belongs **in the PR description, as markdown checkboxes** — not in a separate document nobody opens. Boxes get ticked as they are walked, so the PR itself records what was verified and by whom.

Alongside it, **attach screenshots as evidence.** Drive the flows with Playwright against the preview URL, screenshot at the point where the expected result should be visible, and embed before/after in the description.

This is the change that makes agent output reviewable at volume: the PR stops saying "done" and starts saying *here is the browser doing the thing*. A reviewer ticks boxes against pictures rather than reading a diff and hoping.

```markdown
## Test plan
- [ ] Log in as an existing user -> dashboard loads, no console errors
- [ ] [changed] Export a report -> CSV downloads, opens, has a header row
- [ ] [side-effect] Saved filters still apply after the schema change
- [ ] [regression net] Login still works

## Screenshots
| Before | After |
|---|---|
| ![before](...) | ![after](...) |
Captured by Playwright against the preview URL.
```

**Never tick a box for a step that was not actually run.** An unrun step reported as passing is the single most damaging output of this skill — it launders an unknown into a verified claim. Leave it unticked and say why.

## Before promoting

- Walk the plan on the preview, not on production — and point Playwright at the preview URL too, never localhost
- Confirm the rollback target is the version genuinely live right now, not the newest tag
- Confirm telemetry is capturing on the preview, so a failure produces an event rather than a shrug

Report results honestly. If a step failed, say which one and what you saw — do not summarise a partial pass as a pass. If you did not run a step, say that too; an unrun step reported as passing is the most damaging possible output of this skill.

## Reviewing agent-generated changes

At volume, reading every diff stops being possible, so shift the effort:

1. **Behaviour over diff.** Does the thing do what was claimed? The preview answers this; the diff does not.
2. **Read the boundaries.** Interfaces, migrations, permissions, anything touching money or auth. Skim the interiors.
3. **Look for what is missing** — the error case not handled, the test that asserts nothing, the migration with no rollback. Generated code is much likelier to be plausibly incomplete than wrong-looking.
4. **Be suspicious of a green test suite that was written by the same agent as the code.** Check that the tests would actually fail if the behaviour broke — the cheapest way is to break it deliberately and watch.
