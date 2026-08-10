---
name: agent-personas
description: >
  Use when you need a specific expert reviewer or specialist rather than a
  general-purpose agent — reviewing requirements, prioritising by business value,
  planning a project, reviewing code for maintainability/readability/reliability,
  security review of Flask or MCP servers, git and release work, CloudFormation,
  writing training material, or prototyping which tools a conversational system
  needs. Also use when staffing an adversarial or multi-role campaign and you need
  each role to actually think differently.
---

# Agent Personas

A persona is a system prompt that makes an agent good at **one job** and opinionated about it. It is the cheapest way to get genuinely different output from the same model — a reviewer told to think about reliability finds different problems from one told to think about readability, and both find different problems from "review this code".

Fourteen worked personas live in `references/`. They came from Liz Howard's persona directory (<https://lizthe.dev>) and are free to use, remix and refactor; attribution appreciated, not required.

## Choosing one

| Phase | Persona | Use it for |
|---|---|---|
| **Define** | `requirements-reviewer` | Turning a vague idea into requirements that can be checked. The most detailed of the set. |
| | `value-chain-expert` | Deciding what is worth building first, as a business analyst would. |
| | `project-manager` | Turning requirements into a plan with phases and dependencies. |
| | `distributed-systems-design-reviewer` | Scoring an architecture against a rubric. |
| **Develop** | `git-expert` | Release engineering: branches, merges, recovering a repo someone tangled. |
| | `maintainability-rubric` | Will anyone be able to change this in six months? |
| | `readable-code-reviewer` | Can a human follow it? |
| | `reliability-code-reviewer` | What happens when it fails? |
| **Secure** | `flask-security-expert` | Python web application security review, in depth. |
| | `mcp-reviewer` | Reviewing MCP servers specifically. |
| **Deploy** | `cloudformation-expert` | AWS infrastructure as code. |
| **Document** | `business-training-expert` | Lesson plans and training material from technical content. |
| | `zinemaker` | Print-shaped visual explainers. |
| **Prototype** | `tool-roleplayer` | Play the system by hand to work out which tools it actually needs. |

## How to use one

Read the persona file and adopt it as the operating instructions for that piece of work — either directly, or by handing it to a subagent as its system prompt.

Two rules that decide whether this works:

**Use them one at a time.** Merging three personas into one prompt averages them back into a general-purpose agent and you lose the thing you came for. If you need three perspectives, run three passes and keep the disagreements.

**The disagreement is the output.** When the readability reviewer and the reliability reviewer want opposite things, that tension is real information about a genuine trade-off. Do not resolve it silently — surface both and let a human decide.

## Staffing a campaign

Personas are how the roles in the `run-a-campaign` skill get their distinct viewpoints:

- **Builder** — no persona, or a domain-appropriate one
- **Breaker** — a reviewer persona pointed at the same code, ideally on a different model. `reliability-code-reviewer` and the security personas are the sharpest adversaries here.
- **Reviewer** — the rubric personas, because a rubric produces a score you can compare between runs rather than an opinion you cannot

Rubric-shaped personas (`maintainability-rubric`, `readable-code-reviewer`, `reliability-code-reviewer`, `distributed-systems-design-reviewer`) are deliberately small and scorable. That makes them the right ones to run repeatedly — you can watch a score move across releases, which turns code quality into something with a trend instead of a vibe.

## Writing your own

The set is a starting point, not a canon. A good persona has:

- **One job**, stated in the first sentence
- **A point of view** — what it cares about more than everything else
- **A rubric or checklist**, if the output should be comparable between runs
- **A stated output format**, so results can be diffed
- **Explicit permission to say the work is fine** — a reviewer that must find something will invent something, which is the same Goodhart failure described in `run-a-campaign`

Keep them short unless depth genuinely earns it. The two largest here (`requirements-reviewer`, `flask-security-expert`) are long because they carry real domain checklists; the rubrics are a few hundred bytes and work just as hard.
