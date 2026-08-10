---
name: bootstrap-hosting
description: >
  Use when the user needs somewhere to deploy — standing up a server as a Docker
  host, adding an SSH alias, installing a self-hosted PaaS (Coolify), putting DNS
  and CDN in front (Cloudflare), or storing secrets in a vault (Vaultwarden) and
  scoping tokens. Also use when they ask "where should I deploy this?", when they
  are paying per-app for many small apps, or when secrets are living in .env files
  they copy between machines.
---

# Bootstrap Hosting

Get the user to **one machine they control**, running as many containers as they like, with boring deploys, a CDN in front, and secrets somewhere neither they nor an agent has to paste.

The vendors below are one working combination, not the point. The shape is: **a box, a PaaS, an edge, a vault.** Swap any piece; keep the shape.

## Order matters

Do these in order. Each one makes the next less frightening.

1. SSH alias — so they will actually log in
2. Docker host — so anything can run
3. PaaS — so deploys stop being a ritual
4. DNS + CDN — so it has a real address
5. Vault — so secrets stop living in the repo

## 1. SSH alias first

Before anything else, give the server a short name. A user who has to recall an IP, a username and a key path will avoid their own server.

Write an entry into `~/.ssh/config`:

```
Host myserver
    HostName 203.0.113.10
    User deploy
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
```

Then `ssh myserver` works, and so does `scp file myserver:/tmp/`.

**Explain the four lines.** The user does not need to understand SSH to benefit from this, but they should be able to add the next host themselves. Do not skip the explanation because it seems obvious — this is frequently the first time someone realises the config file exists.

## 2. Docker host

Standard hardening, in this order, explaining each step **before** running it:

- Docker engine + compose plugin
- A non-root user in the `docker` group
- SSH key auth only; `PasswordAuthentication no`
- A firewall permitting only 22/80/443 plus whatever the user actually needs
- Unattended security upgrades
- Log rotation, so the disk does not silently fill

**Call out the lockout risks explicitly.** Disabling password auth and enabling a firewall are the two steps that can lock the user out of their own machine. Confirm they have a working key-based login in a *second* terminal before applying either. Never close the only working session.

Cheap ARM instances (e.g. Hetzner CAX-series) are the usual sweet spot: the economics change from per-app to per-machine, and a modest box runs a surprising number of containers.

## 3. Self-hosted PaaS

Install [Coolify](https://coolify.io) (or Dokku, or CapRover). What the user gets back, and should be told they are getting:

- Deploy from a git branch, automatically
- Environment variables with a UI
- Logs without `docker logs` incantations
- **Rollback to a previous image** — the single most valuable button
- Automatic HTTPS via Traefik + Let's Encrypt, so certificates stop being a recurring task

Point deploys at a **branch**, not at "whatever is on my laptop". See the `release-process` skill.

## 4. DNS and CDN

Cloudflare's free plan is genuinely sufficient: DNS, caching, and a proxy so the origin address is not what the internet talks to.

- Set SSL/TLS mode to **Full (Strict)** so the Cloudflare→origin hop is encrypted *and* verified. "Flexible" leaves that hop in plaintext and is a common silent mistake.
- Tell the user **what is now cached that they did not expect**, and how to purge it. A cached page that will not update after a deploy is the classic first Cloudflare surprise.
- Proxying hides the origin IP, which is a real security benefit — but means the origin must not be reachable directly if that is the goal.

## 5. Secrets in a vault

[Vaultwarden](https://github.com/dani-garcia/vaultwarden) is a self-hosted, Bitwarden-compatible server with a CLI, so both the user and their agents can fetch a secret without it living in a repo or a chat log.

**Scope every token to the narrowest thing that works.** When issuing a token for an agent, state plainly:

- what this token still permits beyond the intended task
- what the blast radius is if it leaks
- how it gets rotated, and who would notice if it were used

An agent's token should not be able to do things the user would be upset about. If the only available scope is broader than the task, say so rather than quietly using it.

Never write secrets into the repo, into `.env` files that get copied between machines, or into your own output. Mask them when displaying: `sk-…f4a2`.

## Availability: ask before assuming

Get an honest answer to "how much downtime is actually acceptable?" before designing anything. See the `wire-telemetry` skill for measuring it.

| Target | Allowed downtime | What it really costs |
|---|---|---|
| Side project | Whatever happens | Nothing. A legitimate answer — just say it out loud. |
| 99% | ~7 hours/month | One box, backups, fix it when noticed. |
| 99.9% | ~43 min/month | Alerting that reaches a human; a rehearsed rollback. |
| 99.99% | ~4 min/month | Redundancy and an on-call rota. A staffing decision, not a technical one. |

Most people need 99% and think they need 99.99%. Push back gently: a higher target is not free, and the cost is paid in evenings.

## Backups are the restore, not the dump

A backup nobody has restored is a hypothesis. Whenever you set up backups, also write down the restore procedure and **time it once** against a machine that does not already exist. Report the actual number.
