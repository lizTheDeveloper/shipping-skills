# Shipping Skills

A set of Claude Code skills for the part of software development that agents make *harder*, not easier: knowing what you have, whether it works, and whether it is getting better.

Agents remove the bottleneck on writing code. They do not remove the bottleneck on **understanding what you now own**. These skills cover the process that keeps up: release branches, versioning, telemetry, verification, documentation, and somewhere to deploy.

They are deliberately generic — no company-specific hosts, tokens or container IDs. Worked examples come from a live system, but every vendor is swappable.

## The skills

| Skill | Use it when |
|---|---|
| **bootstrap-hosting** | You need somewhere to deploy. A box, a PaaS, a CDN, a vault — plus SSH aliases and honest uptime targets. |
| **release-process** | Code reaches production in an unclear way. Release branches, what PRs target, preview deploys, who is allowed to promote. |
| **version-and-claim** | You cannot tell whether the project is getting better or worse. Semver, cohorts as release boundaries, falsifiable release claims, finding regressions. |
| **wire-telemetry** | You learn about bugs from users. Error capture across server/client/jobs, errors→issues with dedup, SLOs you can measure. |
| **verify-release** | "I think it works." A human-walkable test plan against a preview URL, and how to review agent output at volume. |
| **explain-this-project** | You do not understand your own codebase. Documentation written for the operator, not the next agent. |
| **run-a-campaign** | Driving a body of work to completion — `/goal`, builder/breaker/reviewer roles on different models, evolutionary budget allocation, provable rewrites. |
| **detect-drift** | Docs, tests or specs have quietly stopped matching the code. The best candidate for a scheduled routine — it reads and files issues, and changes nothing. |

## Install

Copy the skills into a project (or into `~/.claude/skills/` to have them everywhere):

```bash
git clone https://github.com/lizTheDeveloper/shipping-skills.git
cp -r shipping-skills/skills/* ~/.claude/skills/
```

Claude invokes them by description, so you generally do not need to name them. You can also ask directly: *"use the release-process skill on this repo."*

## The problem they solve

You build a great deal, very fast, and take **one step forward and two steps back** without noticing.

That is what high-output development looks like from the outside when there is no way to tell whether the thing is improving. The fix is not discipline. It is a few pieces of unglamorous machinery:

- **A release process**, so you know what is live and what changed
- **Telemetry**, so failures find you instead of the other way round
- **A claim you could be wrong about**, so a regression is detectable rather than a feeling
- **A test plan**, so "it works" means someone used it
- **Documentation for you**, so you can still review what you own
- **Drift detection on a schedule**, because docs, tests and specs rot silently and nobody remembers to look

## A note on autonomy

Every skill here draws the same line: automation may compute the next version, draft the notes, open the PR, prepare the rollback tag and run the checks — and then stop.

**A human promotes to production.** The only thing that fires unsupervised is the rollback, because an unnecessary rollback is cheap and an unnecessary deploy is not.

## License

MIT.
