---
name: muster
description: Start, stop, and inspect a project's dev servers (web servers, background workers, docker infra) via `muster`, which runs one feature's stack at a time on fixed ports. Use BEFORE launching any dev server, worker, or `docker compose` by hand — and whenever the question is "is the app running?", "why did the server die?", "bring up the services for this worktree", or a dev port is already in use.
---

# muster — one feature's dev stack at a time

`muster` owns the dev servers for a project. Ports are **fixed**, so only one
*occupant* (a feature worktree, or `main`) can be live per project. Activating one
**vacates** whatever was running.

## Rule 0 — never start services by hand

Do **not** run the dev server, background worker, or `docker compose up` directly
in a muster-managed repo. You will collide with muster's fixed ports and leave
orphaned processes muster can't see or clean up. Every start/stop goes through
`muster`.

To find out whether the repo you're in is managed, and what's live anywhere:

```sh
muster projects     # every configured project + its current occupant
muster status       # this project (inferred from cwd): occupant + per-service state
```

If `muster status` says `not inside a known project repo`, this repo isn't
managed — start things however the repo's own docs say.

Everything muster knows about a project comes from config
(`~/.config/muster/config.yaml`) and a `.muster.yaml` in each repo. Read those if
you need to know which services exist; don't assume.

## Rule 1 — `cd` into the worktree, run **bare** `muster up`

```sh
cd /path/to/the/worktree && muster up
```

Never type the feature name. muster's feature identifier is the **git branch**,
but herdr's worktree *directory* is a slug of it, and they routinely differ:

```
branch=add-search-filters   dir=search-work        (branch renamed after creation)
branch=Fix-Date-Parsing     dir=fix-date-parsing   (case folded)
branch=fix-a&b-handling     dir=fix-a-b-handling   (& would break the shell unquoted)
```

Guessing from the directory name gives `no '<feature>' worktree`, or silently
resolves the wrong thing. Bare `muster up` infers project + branch from cwd and is
always right. If you must name a feature explicitly, take it from the `branch`
field of `herdr worktree list --cwd <repo> --json` and single-quote it.

## Rule 2 — check occupancy before taking the seat

Always `muster status` first:

| status says | do this |
|---|---|
| `<project>: (not running)` | seat is free — `muster up` |
| `occupant=<your branch>` | already yours. Don't re-`up`. Verify health; `muster restart <svc>` if a service died |
| `occupant=<another branch>` | **STOP and ask the user.** `up` would kill their running stack mid-work |

Never auto-vacate another occupant. Other agents and the user share this seat.
When you ask, say exactly what's live and what you'd replace it with.

## Rule 3 — confirm it actually booted

`muster up` exits after ready-gating, but a service can still be dead. Verify:

```sh
NO_COLOR=1 muster status
```

```
myproj  occupant=add-search-filters  session=muster-myproj
  api              running            (add-search-filters) port 4000 bound
  worker           running            (add-search-filters)
  web              exited             (main)   port 3000 free
  docker:api       compose  (5 containers up)
```

Columns are `service · state · (worktree it's using) · port`. Check three things:

1. **state** is `running` — not `exited` (process died) or `stopped` (no pane).
2. **port** is `bound` for every service that declares one.
3. **`(using)`** is the worktree you expected, for *every* repo — see Rule 4.

Anything wrong → `muster logs <svc>`. Report what you found; don't declare success
off `muster up`'s exit code alone.

> `muster logs` reads the pane's recent output — **up to ~1000 lines** of
> scrollback, herdr's ceiling for a single read. Still not unlimited history:
> anything older is gone, and so is everything from before a `restart` (which
> spawns a fresh, empty pane) or a `down`. If a crash predates the window,
> `muster restart <svc>` and read it fresh.

Use `NO_COLOR=1` whenever you parse output.

## Rule 4 — cross-repo: assert before, verify after

In a multi-repo project, branch names for the *same* work often differ per repo.
muster resolves each repo independently:

```
`use:` pin  →  the occupant's own worktree  →  main
```

So a sibling repo whose branch name doesn't match **falls back to `main` and
`muster up` still reports success.** You get a plausible stack running the wrong
backend. Silence is the failure mode.

**Never infer the pairing.** Only pin a sibling worktree when the user, the task
prompt, or your own orchestration explicitly established it. If you suspect a
sibling dependency but weren't told, ask.

**Assert before.** State the intended mapping before bringing anything up:

> Bringing up `myproj`: `client` → `add-search-filters`, `api` →
> `search-index-endpoint` (pinned).

**Then pick a mechanism.**

*Durable* — a `use:` pin in the **occupant worktree's own** `.muster.yaml`.
Survives `up`/`restart` and outranks a same-named worktree. Use when the
dependency is part of the task:

```yaml
# in the client worktree's .muster.yaml
use:
  api: search-index-endpoint
```

Keys are **repo directory names**, values are **branch names**. Remove the pin once
the dependency merges — it wins permanently otherwise. Check whether
`.muster.yaml` is gitignored in that repo before editing; if it's tracked, the pin
would land in the PR diff, so prefer a swap.

*Ephemeral* — re-point one repo on an already-live stack. No file edit, but
**wiped by the next `muster up`**. Use for a one-off check. Takes a repo **path**
(unlike the pin's dir name):

```sh
muster <project> swap /path/to/repo search-index-endpoint
```

**Verify after.** Re-read the `(using)` column for every service. If a repo landed
on `main` and you didn't intend that, the stack is wrong — say so, don't proceed.

To see what a sibling repo actually has:
`herdr worktree list --cwd <repo> --json`.

## Troubleshooting

| symptom | cause | what to do |
|---|---|---|
| `<repo>: no .muster.yaml in <path> — skipping its services` | the worktree is missing its service file, so **that repo starts nothing** while `up` still "succeeds" | Report it — worktree creation should have supplied that file, so its absence is a bug worth fixing at the source. Don't hand-author or copy a service file to work around it |
| `another muster operation is already running for '<project>'` | another agent or the dashboard holds the project's `flock` | **Do not retry-loop.** Wait, then `muster status` — someone else may be taking the seat |
| service `exited` right after `up` | crashed on boot | `muster logs <svc>` for the traceback. Fix the cause, then `muster restart <svc>` — not a bare `up` |
| `ports still in use after teardown` | an orphaned process holds the port | `lsof -i :<port>`. Usually a hand-started server (Rule 0) |
| ready-gate hangs, then continues | the service's `ready:` regex never matched | It may still be fine — check `port … bound`. Tune with `MUSTER_READY_WAIT_TIMEOUT` (seconds) |
| docker/compose errors on `up` | Docker isn't running | Start Docker, then retry. muster refuses to start services against missing infra |
| `not inside a known project repo` | cwd isn't in a configured repo | `muster projects`, then use the explicit form `muster <project> <cmd>` |

Containers are shared infra: left running on `down` and across swaps. Manage them
with `muster <project> docker` (lazydocker) — never `docker compose down`.

## Command reference

```sh
muster status                 # what's live, per-service state, ports  (read-only)
muster logs <svc>             # a service's recent pane output, ~1000 lines (read-only)
muster projects               # all projects + occupants               (read-only)
muster up                     # take the seat for this worktree (vacates the current occupant)
muster restart <svc>          # restart one service (skips after_ready hooks)
muster restart                # restart the whole project
muster swap <repo-path> <br>  # re-point one repo, ephemerally
muster down                   # stop this project's services, free the ports
```

Read-only commands are always safe. `up`/`down`/`restart`/`swap` mutate the shared
seat — they run in a detached worker (surviving a closed terminal), and only one
runs per project at a time. All of them accept an explicit `muster <project> <cmd>`
form when cwd inference isn't what you want.

## Scope

This skill covers getting the stack up and confirming it's healthy, and nothing
past that. What to do with a running stack — exercise it, test it, debug against
it — and whether to `muster down` when you're finished belong to the task that
brought you here. Decide those from that context; just be explicit in your summary
about whether you left the seat occupied.
