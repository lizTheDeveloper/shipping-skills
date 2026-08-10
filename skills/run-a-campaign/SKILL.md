---
name: run-a-campaign
description: >
  Use when driving a body of work to completion with agents rather than one task
  at a time — building out a roadmap, a rebuild, a re-implementation, a prototype,
  or a provably feature-complete rewrite. Covers /goal as the completion engine,
  TDD then E2E behaviour tests, adversarial testers on a different model whose job
  is to break the code, evolutionary budget allocation between them, and driving
  the defect rate down.
---

# Run a Campaign

A campaign is a body of work driven to a **verifiable end state** by several agents with different jobs, rather than one agent doing tasks until it feels finished.

Use it for a roadmap phase, a rebuild, a re-implementation, a prototype you intend to replace, or a rewrite you need to prove is complete.

## The engine: `/goal`

`/goal <condition>` keeps Claude working across turns until a **separate evaluator model** confirms the condition holds. That separation is the point: completion is judged by something other than the model that did the work.

```
/goal every task in Phase 1 is implemented, each has a test that fails when the
behaviour is removed, `npm test` exits 0, and lint is clean. Do not modify files
outside src/ and test/. Or stop after 25 turns.
```

- `/goal` alone shows status — condition, turns evaluated, token spend, and the evaluator's most recent reason
- `/goal clear` stops it
- `claude -p "/goal …"` runs the whole loop headless in one invocation

Writing a condition that works:

- **The evaluator reads the transcript. It does not run commands or read files.** So the condition must be something Claude's own output demonstrates. `npm test exits 0` works; "the code is good" never will.
- **State the check** — the command and the expected result.
- **State the constraints** that must not change on the way there ("no other test file is modified"). Without these, a stuck campaign will start editing tests until they pass.
- **Bound it.** Add "or stop after N turns". An unbounded goal on an unreachable condition grinds.

Pair with auto mode to run unattended — and only after the goal is scoped tightly enough that unattended is a reasonable thing to be.

## The roles

Run these as separate agents, ideally on **different models**.

| Role | Job | Done when |
|---|---|---|
| **Builder** | TDD the feature — failing test, then implementation. Then an E2E test describing the *behaviour*, not the implementation. | Its own tests pass. |
| **Breaker** | Pointed at the same feature on a different model, told to **write tests that break it**. Edge cases, hostile input, ordering, concurrency, the paths the builder found boring. | It can no longer produce a genuinely failing test. |
| **Reviewer** | Runs the PR review checklist. Boundaries, migrations, permissions, anything touching money or auth. | Checklist clean, with stated reasons. |

### Reaching the other models

**OpenRouter is the best backend for anything that isn't Claude.** One account and one credential reach models from every major provider, which is what makes a genuinely mixed panel practical instead of an integration project.

[Ori](https://openrouter.ai/docs/guides/ori/harness) runs the agent CLI you already use on top of it:

```bash
curl -fsSL https://openrouter.ai/labs/ori/install.sh | bash
ori login                                    # OAuth — no key to create or paste
ori claude --model anthropic/claude-sonnet-4.6
ori codex     ori hermes     ori opencode
```

Your flags and workflow pass through unchanged, so a breaker is the same command with a different `--model`.

Two practical notes:

- Check [discounted models](https://openrouter.ai/collections/discounted-models) before allocating a large campaign budget — the cheapest provider for a given model is often running a promotion, and adversarial testing is exactly the high-volume, lower-stakes work worth spending discounted tokens on.
- Routing through a gateway sets a custom API base URL, which **disables Claude Code's Remote Control** (it requires talking to `api.anthropic.com` directly). Run a gateway-routed campaign and a phone-driven session as separate sessions.

**Why a different model matters:** an agent that wrote the code writes tests that agree with the code. The suite is internally consistent and completely indifferent to whether the requirement was met. Disagreement is the product here, not throughput.

## Evolutionary allocation

Do not decide in advance which model is the best adversary — you cannot know, and it changes as the code changes.

1. Start with every model capable of holding the task
2. Score each breaker on **non-trivial failing tests produced**
3. A breaker that stops finding real breaks gets **fewer runs** next round
4. The one still drawing blood gets more tokens and runs longer on those features

Over a few rounds the budget concentrates on whichever model is actually adversarial for *this* codebase.

**Guard the scoring function.** A breaker rewarded for red tests will write assertions that are simply wrong. Require every failing test to name the behaviour it believes is incorrect and why; have the reviewer discard noise before scoring. Equally, a builder rewarded for green writes tests that assert nothing. Both directions are Goodhart, and both need a check that isn't the thing being scored.

## Provably feature-complete rewrites

This is the technique that was previously too expensive to do by hand.

1. Build an E2E suite covering **every path** through the current implementation, treating existing behaviour as the specification — bugs included
2. Test **through the public interface only**, so the tests survive the internals changing completely
3. Rewrite behind that suite
4. Get an explicit list of the paths that **could not** be covered — that list is exactly the part of the rewrite that will not be provably equivalent, and it is the only part needing human judgement

Ask for that uncovered list every time. An agent will otherwise report coverage as complete when it means "complete for the paths I found".

## Driving the defect rate down

Running a team of agents is the same job as running a team of people: you are trying to drive down defects, problems and error rate.

- After every defect, ask **"what in the process allowed this bug to occur?"** — not whose fault it was. The answer is almost always a missing gate, not a careless agent.
- Fix the process, then let the fix be automatic. See the `detect-drift` skill.
- The goal is to drive defects **down**, not to zero. Past a point the cost of the next nine exceeds what it buys, and saying where that point is for this project is a decision, not an oversight.

Report the defect rate as a trend, never as a target handed to the agents — they Goodhart a target as readily as people do.
