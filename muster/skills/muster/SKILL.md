---
name: muster
description: Start, stop, and inspect a project's dev servers (web servers, background workers, docker infra) via `muster`. Use BEFORE launching any dev server, worker, or `docker compose` by hand, and whenever a dev port is already in use or a service died unexpectedly.
---

# muster — one feature's dev stack at a time

`muster` owns the dev servers for a project. Ports are **fixed**, so only one
*occupant* (a feature worktree, or `main`) can be live per project. Activating one
**vacates** whatever was running.

Each service runs as a herdr-core (`hc`) **terminal**, which the Herdr app shows
as a **tab** in the project's **space** `muster-<project>` (named
`<project> · <occupant>`).

## Rule 0 — every start and stop goes through muster

Running a dev server, background worker, or `docker compose up` by hand in a
muster-managed repo collides with muster's fixed ports and leaves orphaned
processes muster can't see or clean up.

To find out whether the repo you're in is managed, and what's live anywhere:

```sh
muster projects     # every configured project + its current occupant
muster status       # this project (inferred from cwd): occupant + per-service state
```

Set `NO_COLOR=1` on any muster command whose output you parse.

If `muster status` says `not inside a known project repo`, this repo isn't
managed — start things however the repo's own docs say.

## Rule 1 — check occupancy before taking the seat

Always `muster status` first:

| status says | do this |
|---|---|
| `<project>: (not running)` | seat is free — `muster up` |
| `occupant=<your branch>` | already yours. Don't re-`up`. Verify health; `muster restart <svc>` if a service died |
| `occupant=<another branch>` | **STOP and ask the user.** `up` would kill their running stack mid-work |

The seat is shared with other agents and the user, so leave another occupant
running until they tell you otherwise. When you ask, say exactly what's live and
what you'd replace it with.

## Rule 2 — `cd` into the worktree, run **bare** `muster up`

```sh
cd /path/to/the/worktree && muster up
```

Let cwd name the feature. muster's feature identifier is the **git branch**, but
a worktree's *directory* name is often something else (the app creates them
under `~/.herdr/worktrees/<repo>/<branch>`, but older or hand-made ones vary):

```
branch=add-search-filters   dir=search-work        (branch renamed after creation)
branch=Fix-Date-Parsing     dir=fix-date-parsing   (case folded)
branch=fix-a&b-handling     dir=fix-a-b-handling   (& would break the shell unquoted)
```

Guessing from the directory name gives `feature '<x>' has no worktree in any
'<project>' repo`, or silently resolves the wrong thing. Bare `muster up` infers
project + branch from cwd and is always right. If you must name a feature
explicitly, take it from the `branch` line of `git -C <repo> worktree list
--porcelain` (minus `refs/heads/`) and single-quote it.

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

Columns are `service · state · (worktree it's using) · port`; `session` is the
app space id. Check three things:

1. **state** is `running` (live terminal) — not `exited` (the program ended; the
   app drops its tab, so look here, not for the tab) or `stopped` (never
   started, or gone from herdr-core).
2. **port** is `bound` for every service that declares one.
3. **`(using)`** is the worktree you expected, for *every* repo.

Anything wrong → `muster logs <svc>`. Report what you found; don't declare success
off `muster up`'s exit code alone.

> `muster logs` reads the terminal's output — **up to ~1000 lines**, one `hc
> read`'s ceiling — and works on `exited` services too: the core keeps a finished
> terminal's output until teardown. Older lines are gone, and so is everything
> from before a `restart` (which starts a fresh terminal) or a `down`. If a crash
> predates the window, `muster restart <svc>` and read it fresh.

## Multi-repo projects

muster resolves each repo independently — `use:` pin → the occupant's own
worktree → `main` — so a sibling repo whose branch name doesn't match **falls
back to `main` while `up` still reports success**. You get a plausible stack
running the wrong backend, and nothing errors. Silence is the failure mode.

Read [`CROSS-REPO.md`](CROSS-REPO.md) before bringing up a project that spans more
than one repo, and whenever you need repo paths, space ids (`session`), or the
service-file name.

## Troubleshooting

| symptom | cause | what to do |
|---|---|---|
| `<repo>: no .muster.yaml in <path> — skipping its services` | the worktree is missing its service file, so **that repo starts nothing** while `up` still "succeeds" | Report it — worktree creation should have supplied that file, so its absence is a bug worth fixing at the source. Don't hand-author or copy a service file to work around it |
| `a muster job is already running for '<project>'` | another agent, the Herdr app's Muster panel, or an earlier job holds the project lock | **Do not retry-loop.** Wait, then `muster status` — someone else may be taking the seat. `hc ls --label muster.job=<project>` shows the job; `hc read <t>` its output |
| service `exited` right after `up` | crashed on boot | `muster logs <svc>` for the traceback. Fix the cause, then `muster restart <svc>` — not a bare `up` |
| service `exited` at once with `command not found` or missing env vars | services run as `/bin/sh -c <command>` with herdr-core's environment: no `.zshrc`, no direnv (PATH does include mise shims) | Report it to the user as an environment gap. Leave the service command and muster's setup as they are |
| `ports still in use after teardown` | an orphaned process holds the port | `lsof -i :<port>`. Usually a hand-started server (Rule 0) |
| ready-gate hangs, then continues | the service's `ready:` regex never matched | It may still be fine — check `port … bound`. Tune with `MUSTER_READY_WAIT_TIMEOUT` (seconds) |
| docker/compose errors on `up` | Docker isn't running | Start Docker, then retry. muster refuses to start services against missing infra |
| `not inside a known project repo` | cwd isn't in a configured repo | `muster projects`, then use the explicit form `muster <project> <cmd>` |

Containers are shared infra: left running on `down` and across swaps. Manage them
with `muster <project> docker` (lazydocker, opened as a tab in the project's
space) — never `docker compose down`.

## Commands

`muster help` lists every command and its arguments. What it won't tell you:

**Read-only, always safe:** `status`, `logs <svc>`, `projects`. (`state` is all
projects as JSON for UIs — use `status`.)

**Mutating — these take the shared seat:** `up`, `down`, `restart [<svc>]`, `swap`.
Each runs as an `hc` job terminal: it survives a closed caller, streams its output
to your CLI, stops on Ctrl-C, and exits with the job's code. Only one runs per
project at a time; a second is refused while the first is in flight. Run them
plain and blocking so you see the result — `--detach` returns `{job,label}` at
once and is meant for UIs. All accept an explicit `muster <project> <cmd>` form
for when cwd inference isn't what you want.

Teardown (`down`, and `up`'s vacate) stops every terminal labelled with the
project, including ones no lock recorded — so `down` also reaps strays when
`status` says `(not running)`.

## Scope

This skill covers getting the stack up and confirming it's healthy, and nothing
past that. What to do with a running stack — exercise it, test it, debug against
it — and whether to `muster down` when you're finished belong to the task that
brought you here. Decide those from that context; just be explicit in your summary
about whether you left the seat occupied.
