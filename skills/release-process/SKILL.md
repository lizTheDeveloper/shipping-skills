---
name: release-process
description: >
  Use when setting up or fixing how code gets from a branch to production —
  named release branches, what PRs target, preview deployments, CI gates, keeping
  a release branch in sync with production, and who is allowed to promote. Also
  use when the user merges straight to production, has long-lived feature branches
  that will not merge, ships from a laptop, or cannot say what is currently live.
---

# Release Process

The goal is that at any moment the user can answer three questions: **what is live, what is about to be live, and what changed between them.** Everything here exists to keep those answerable when agents are producing changes faster than anyone reads them.

## The two-lane model

During a release cycle, run **two** named branches:

| Branch | Carries | Ships |
|---|---|---|
| **patch** | Bug fixes, docs, logging, config | Often — roughly daily |
| **unstable** | New behaviour, and things that never worked | At the release boundary |

Sorting rule, and it is genuinely this simple: **is this fixing something that is broken now, or adding something new?** Broken now → patch. New → unstable.

Why two lanes: it lets you ship an urgent fix without dragging along half-finished features, which is the thing that otherwise forces people to merge straight to production.

## Rules that do the work

**PRs target a release branch, never production directly.** If someone can push to production, eventually someone will, at the worst possible time.

**Keep the release branch continuously in sync with production.** A release branch that has drifted for weeks is how the merge that breaks everything gets built. Merge production into it (or rebase) on a schedule, not when it hurts. If it has already drifted badly, reconcile it *before* adding anything else — and expect squashed cherry-picks to show as drift even when the content is already present.

**One CI check that actually blocks the merge.** One is enough. What matters is that it genuinely stops things — a gate that everyone routinely overrides is a habit, not a control.

**A human promotes to production.** Automation may compute the next version, draft the release notes, open the PR, and prepare the rollback tag. It stops there. The only thing that should fire unsupervised is the **rollback**, because the cost of an unnecessary rollback is low and the cost of an unnecessary deploy is not.

## Preview deployments

Every deploy branch gets a running URL someone can click.

This is what turns "the diff looks fine" into "I used it and it worked", and at agent throughput it is the only realistic review mechanism — nobody is reading every line of a 300-commit week.

- Previews per **deploy branch**, not per PR. Per-PR previews sound thorough and mostly generate cost and noise.
- **Cap how many exist at once and evict the oldest.** Uncapped previews quietly consume the host; this is a real outage cause, not a theoretical one.
- Preview environments that share a production database are a trap. If they must, make them obviously non-destructive and say so loudly.

## Issues are the ledger

If it is not an issue, it does not exist. Not chat scrollback, not the user's memory.

This matters far more with agents in the loop: work is produced faster than a person can hold it, and an issue is the only artifact that survives a context window ending. Wire error reports into issues automatically — see the `wire-telemetry` skill.

## Setting this up

When asked to establish a release process, produce:

1. The two branches, created and pushed
2. Branch protection: no direct pushes to production, PRs require the CI check
3. A `CONTRIBUTING.md` stating which branch takes what, and how to promote
4. The sync mechanism, and what to do when the release branch drifts
5. Preview deploys wired to the deploy branches, with a cap

Then state plainly **what is not enforced by a machine** — anything relying on people remembering is a documented convention, not a control. Do not let a written process be mistaken for an enforced one.

## Worked example

One shape that works, from a live system: `production` *is* the release branch. PRs target it; staging auto-deploys from it, so every merge is exercised on a real environment before anyone promotes it to production. A patch branch ships daily; an unstable branch collects new behaviour and ships at the cycle boundary. One CI check blocks merges. Promotion to production is a human action.

The branch *model* is not portable between projects — a repo whose PRs target `main` needs a different answer. The **rules** are portable. Establish which model the project is already on before proposing changes, and do not carry another project's answer across.
