---
name: dispatch
description: Hand work to a Herdr worktree agent — the dispatch-prompt contract and the write→verify→create→confirm sequence. Load before creating a worktree or spawning an agent.
user-invocable: false
allowed-tools: Bash, Write
---

`herdr worktree create` opens a worktree as its own space under the source repo. The
`jdeff.flow` plugin fires on `worktree.created`, copies the repo's untracked files,
then lays out Claude + a shell. A Claude that finds a dispatch prompt for its branch
launches with it as its first message; one that finds none starts **bare** — no
prompt, no work, and no error anywhere.

## Requirements

- Inside herdr: `test "${HERDR_ENV:-}" = 1`. If not, say so and stop.
- `jdeff.flow` enabled (`herdr plugin list`).

## Confirm before creating

A worktree means a new branch, a new space, and a running agent. Unless the user
invoked a dispatch skill by slash command, or has already asked for parallel or
background work, list what you would create and get a yes first.

## The contract

The prompt goes to `~/.herdr/dispatch/<slug>.md`, where slug is the branch run
through `tr -c '[:alnum:]' '-'` — the layout script uses the identical transform, and
deletes the file when the agent launches with it.

## Sibling worktrees in one project

Dispatching into another repo of the same muster project, for the same work, *is* the
orchestration that establishes a pairing. Left unrecorded, muster resolves that
sibling to `main` and still reports success — a plausible stack running the wrong
backend. `muster projects --json` says which repos share a project.

Two things follow:

- Name the counterpart branch in the sibling's prompt, so its agent works from a
  stated pairing rather than an inferred one.
- Once both worktrees exist, record the pin in whichever one will take the seat, per
  the `muster` skill's cross-repo reference. It has to come after creation — the
  worktree's `.muster.yaml` is seeded by the `worktree.created` hook.

## Sequence

Write every prompt before creating any worktree. The hook consumes the prompt at
creation time, so a worktree created first gets a bare agent in a correct-looking
worktree.

**1. Write each prompt, and prove it exists.** Stop on a zero byte count.

```bash
mkdir -p ~/.herdr/dispatch
branch="<branch>"
f="$HOME/.herdr/dispatch/$(printf '%s' "$branch" | tr -c '[:alnum:]' '-').md"
cat > "$f" << 'EOF'
<prompt>
EOF
wc -c "$f"
```

**2. Create the worktrees** — after every prompt file exists.

```bash
herdr worktree create --cwd "<repo-root>" --branch "$branch" --no-focus
```

**3. Confirm each prompt was consumed.** A file still on disk means a bare agent.

```bash
sleep 3; [ -e "$f" ] && echo "BARE — $branch" || echo "consumed"
```

This is the authoritative check. Agent status is not: a fast agent is already `idle`
when you look, so `idle` cannot separate bare from finished. Report a bare agent as a
failure.

## Flags

- `--cwd <path>` — the repo to branch from. Same repo: `git rev-parse --show-toplevel`;
  cross-project: that repo's absolute path. Never `cd`.
- `--base <ref>` — branch from `<ref>` instead of the repo's current HEAD.
- `--branch <name>` — an existing name checks out, a new name creates.
- `--focus` / `--no-focus` — `--no-focus` keeps you where you are. Always use it for
  more than one worktree.

## Prompt rules

- Self-contained. The agent cannot see your conversation; include referenced context
  verbatim.
- Relative paths only — each worktree has its own root.
- Thin beats thorough. Point at the source of truth (a ticket, a spec file) so the
  agent reads the current version rather than a copy that went stale.
- Delegating a skill: write `Use the skill: /name <args>` and no manual steps.
