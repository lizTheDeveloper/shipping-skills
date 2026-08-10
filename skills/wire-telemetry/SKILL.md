---
name: wire-telemetry
description: >
  Use when a project has no error reporting, when the user finds out about bugs
  from users rather than from tooling, when setting up uptime monitoring or an
  availability target, or when asked to turn error reports into tracked work.
  Covers Sentry-compatible error capture (GlitchTip), server/client/job coverage,
  errors-to-GitHub-issues with deduplication, and SLOs you can actually measure.
---

# Wire Telemetry

Telemetry is the thing people skip because **nothing is visibly broken without it**. That is precisely the point: without it, nothing is visibly broken. You find out from a user, weeks late, if at all.

This is the highest-value single thing most projects are missing, and it pays off the moment the laptop closes.

## Capture all three surfaces

The usual mistake is instrumenting only the web server.

| Surface | Why it gets missed |
|---|---|
| **Server** | Everyone does this one. |
| **Client / browser** | Fails on *their* device, in *their* browser. You will never reproduce it. |
| **Background jobs / workers** | The worst gap. Jobs fail **silently** — no user is watching a cron run, so a broken job can be dead for months. |

Any Sentry-compatible SDK works. [GlitchTip](https://glitchtip.com) is a self-hostable, Sentry-compatible backend, which keeps error data on infrastructure the user controls — a real consideration when stack traces contain user data.

Use separate projects/DSNs per surface (`server`, `client`) so the noise profiles stay separable.

## Do not capture secrets

Before enabling capture, show the user **exactly what a captured event will contain**. Then confirm you are excluding:

- Authorization headers, cookies, session tokens, API keys
- Request bodies on auth, payment and profile endpoints
- Any PII not required to identify the bug

Error trackers are a classic accidental secret store. Assume the payload will be seen by more people than the production database.

## Errors become issues, automatically

Capture alone produces a dashboard nobody opens. The step that changes behaviour is: **each new error becomes a tracked work item without a human noticing it first.**

Wire alerts to a small bridge service that opens an issue in the tracker. Requirements:

- **Deduplicate.** One issue per distinct error, not per occurrence. Without this, one noisy bug buries the tracker within a day and the whole thing gets muted.
- **Throttle recurrences.** Comment on the existing issue, rate-limited — do not reopen or re-notify per event.
- **Label them** so they are filterable and do not drown the human-written backlog.
- Include the stack trace, the culprit, and a link back to the full event.

Two things that reliably bite when building this bridge:

- **Verify the actual webhook payload shape** against a real alert rather than the documentation. Error-tracker webhook formats differ between versions, and some send a chat-style envelope (a `text` field plus `attachments`) rather than a structured issue object.
- If the tracker cannot set custom headers on webhooks, the shared secret has to ride as a query parameter. Note that in the code, and keep the endpoint internal to the network where possible.

## Uptime and SLOs

An availability target is only real if something would tell you that you missed it.

1. Get an honest number — see the `bootstrap-hosting` skill for the cost of each tier
2. Add an external uptime check that hits a **real** endpoint, not a static file
3. Make sure the alert reaches a **human**, on a channel they actually read
4. Write down what happens when it fires, including who rolls back

A health endpoint that returns 200 while the database is down is worse than none — it converts an outage into a silent one. Have it check the dependencies that matter, and keep it cheap enough to poll.

## Reporting back

After wiring telemetry, tell the user plainly:

- what is now captured, per surface
- what is deliberately **not** captured, and why
- where errors land, and what they will see when one fires
- the first real error it catches — because there is almost always one already there, and finding it is the moment the value becomes obvious
