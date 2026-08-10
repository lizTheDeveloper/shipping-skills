---
name: explain-this-project
description: >
  Use when the user needs documentation written for themselves rather than for an
  agent — how the system fits together, what happens on a request, where data
  lives, what breaks and how they would notice. Use when they inherited a codebase,
  when agents built something faster than they could follow, or when they say they
  do not understand their own project.
---

# Explain This Project

Write documentation **for the human who has to operate this**, not for the next agent picking up a task.

This is a real and specific gap. Agents build systems faster than anyone forms a mental model of them, and the distance between *my project works* and *I understand my project* is exactly where confident wrong decisions get made. The user cannot review what they cannot follow.

## Cover these, in this order

1. **What the pieces are** and how they fit — the smallest accurate map. A diagram in text is fine; an exhaustive file listing is not.
2. **What happens when a request comes in** — one concrete path, end to end. This single section does more than the rest combined.
3. **Where the data lives** — stores, what is authoritative, what is derived or cached. Name what would be unrecoverable if lost.
4. **What breaks most often, and how they would notice.** Be specific and honest, including failures that are currently silent.
5. **How to run it from scratch** on a machine that does not have it yet. Every undocumented step surfaces here.
6. **What to do when it is broken at 3am** — where the logs are, how to roll back, what is safe to restart.

## How to write it

- **Plain language.** Expand the jargon. If the user did not choose a technology, do not assume they know why it is there.
- **Explain the parts they did not write.** Anything an agent introduced needs more explanation than anything they typed, not less — that is the whole point.
- **Concrete over general.** Real endpoint names, real table names, real file paths.
- **Say what you are unsure about.** A section marked "I could not determine how X is triggered" is more useful than a confident guess, and it is a finding.

## The important rule

**If a part is confusing to document because the design is confusing, say so plainly instead of writing around it.**

Documentation that smooths over a tangle makes the tangle permanent — it converts a design problem into a comprehension problem and hands it to the reader. When you find yourself writing a paragraph to explain why something is the way it is, that paragraph is a bug report. Surface it:

> **This was hard to document.** Session state is written in three places (`auth.py`, the worker, and a migration hook) with no single owner. I have described what each does, but the reason this section is long is that the design is unclear, not that the topic is complex.

## Keeping it true

Documentation drifts silently and drifted docs are worse than none, because they are trusted.

- Put it in the repo, next to the code, not in a wiki nobody opens
- Note what it was accurate as of
- Regenerate it when the architecture changes rather than patching it line by line
- When asked to update it, **re-read the code first** — do not update the docs from the previous docs
