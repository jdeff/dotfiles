---
name: dispatch
description: How to hand work to a Herdr worktree agent — the dispatch-prompt contract, the write→verify→create→confirm sequence, and prompt-writing rules. Load before creating a worktree or spawning an agent. /worktree, /ticket and /coordinator all build on this.
user-invocable: false
allowed-tools: Bash, Write
---

`herdr worktree create` opens a worktree as its own space grouped under the source
repo. The `jdeff.flow` plugin fires on `worktree.created`, copies the repo's
untracked files, then lays out Claude + a shell. If a dispatch prompt exists for the
new branch, that Claude launches with it as its first message; otherwise it starts
bare.

## Requirements

- Inside herdr: `test "${HERDR_ENV:-}" = 1`. If not, say so and stop.
- `jdeff.flow` enabled (`herdr plugin list`).

## Confirm before creating

A worktree means a new branch, a new space, and a running agent. Unless the user
invoked a dispatch skill by slash command, or has already asked for parallel or
background work, list what you would create and get a yes first.

## The contract

The prompt goes to `~/.herdr/dispatch/<slug>.md`, where slug is the branch run
through `tr -c '[:alnum:]' '-'` — the layout script uses the identical transform. The
file is deleted when the agent launches with it.

## Sequence

Never create the worktree first. The hook consumes the prompt at creation time; if
it isn't there yet you get a bare Claude idling in a correct-looking worktree, and
nothing reports an error.

**1. Write every prompt file, and prove each exists.** Stop on a zero byte count.

```bash
mkdir -p ~/.herdr/dispatch
branch="<branch>"
slug=$(printf '%s' "$branch" | tr -c '[:alnum:]' '-')
f="$HOME/.herdr/dispatch/$slug.md"
cat > "$f" << 'EOF'
<prompt>
EOF
wc -c "$f"
```

**2. Create the worktrees** — only after every prompt file exists.

```bash
herdr worktree create --cwd "<repo-root>" --branch "$branch" --no-focus
```

**3. Confirm each prompt was consumed.**

```bash
sleep 3; [ -e "$f" ] && echo "BARE — $branch never got its prompt" || echo "consumed"
```

This is the authoritative check. Agent status is not: a fast agent is already `idle`
by the time you look, so `idle` cannot distinguish "never prompted" from "finished".
Report an unconsumed prompt as a failure, never as success.

## Flags

- `--cwd <path>` — the repo to branch from. Same repo: `git rev-parse --show-toplevel`.
  Cross-project: that repo's absolute path. Never `cd`.
- `--base <ref>` — branch from `<ref>` instead of the repo's current HEAD.
- `--branch <name>` — an existing name checks out, a new name creates.
- `--focus` / `--no-focus` — `--no-focus` keeps you where you are. Always use it for
  more than one worktree.
- `--label <text>` — space label; defaults to the branch slug.

## Prompt rules

- Self-contained. The agent cannot see your conversation; include referenced context
  verbatim.
- Relative paths only — each worktree has its own root.
- Thin beats thorough. Point at the source of truth (a ticket, a spec file) and let
  the agent read it itself rather than pasting a copy that goes stale.
- Re-read any markdown file you quote, so you quote the current version.
- Delegating a skill: write `Use the skill: /name <args>` and no manual steps.

A dispatched agent starts fresh with only its prompt, so it will not recursively
dispatch.
