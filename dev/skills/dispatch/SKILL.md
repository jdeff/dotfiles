---
name: dispatch
description: Hand work to a worktree agent — the dispatch-prompt contract, and the write→verify→create→confirm sequence. Load before creating a worktree or spawning an agent.
user-invocable: false
allowed-tools: Bash, Write
---

`worktree-create` adds the worktree under `~/src/.worktrees/<repo>/<branch-slug>`,
copies the repo's untracked files, then opens it as its own session in whichever
multiplexer you are running in, with Claude and a shell. A Claude given a dispatch
prompt for its branch launches with it as its first message; one that finds none
starts **bare** — no prompt, no work, and no error anywhere.

## Requirements

Inside a Herdr or Rex terminal. `worktree-create` checks this before touching git and
exits non-zero otherwise; say so and stop.

## Confirm before creating

A worktree means a new branch, a new session, and a running agent. Unless the user
invoked a dispatch skill by slash command, or has already asked for parallel or
background work, list what you would create and get a yes first.

## The contract

The prompt goes to `~/.local/state/dispatch/<slug>.md`, where slug is the branch run
through `tr -c '[:alnum:]' '-'` — `worktree-create` uses the identical transform, and
deletes the file once the agent's session exists.

## Sibling worktrees

Dispatching into another repo of the same muster project, for the same work, is what
establishes a **pin** — muster otherwise resolves that sibling to `main` silently.
`muster projects --json` says which repos share a project.

- The sibling's prompt names its counterpart branch, so its agent works from a stated
  pin rather than an inferred one.
- Once both worktrees exist, write the pin per the `muster` skill's cross-repo
  reference, in whichever worktree takes the seat. Creation comes first: it seeds the
  `.muster.yaml` the pin lives in.

## Sequence

Write every prompt before creating any worktree. Creation consumes the prompt, so a
worktree created first gets a bare agent in a correct-looking worktree.

**1. Write each prompt, and prove it exists.** Stop on a zero byte count.

```bash
mkdir -p ~/.local/state/dispatch
branch="<branch>"
f="$HOME/.local/state/dispatch/$(printf '%s' "$branch" | tr -c '[:alnum:]' '-').md"
cat > "$f" << 'EOF'
<prompt>
EOF
wc -c "$f"
```

**2. Create the worktrees** — after every prompt file exists.

```bash
# prints {host, session, agent, path}
worktree-create --cwd "<repo-root>" --branch "$branch" --no-focus
```

**3. Confirm each prompt was consumed.** A file still on disk means a bare agent.

```bash
sleep 3; [ -e "$f" ] && echo "BARE — $branch" || echo "consumed"
```

This is the authoritative check. Agent status is not: a fast agent is already `idle`
when you look, so `idle` cannot separate bare from finished. Report a bare agent as a
failure. A failed create exits non-zero and leaves the file, so the check reads the
same.

## Flags

- `--cwd <path>` — the repo to branch from. Same repo: `git rev-parse --show-toplevel`;
  cross-project: that repo's absolute path. Never `cd`.
- `--base <ref>` — branch from `<ref>` instead of the repo's current HEAD.
- `--branch <name>` — an existing name checks out, a new name creates.
- `--focus` / `--no-focus` — `--no-focus` keeps you where you are. Always use it for
  more than one worktree. The default is `--no-focus`.

## Prompt rules

- Self-contained. The agent cannot see your conversation; include referenced context
  verbatim.
- Relative paths only — each worktree has its own root.
- Thin beats thorough. Point at the source of truth (a ticket, a spec file) so the
  agent reads the current version rather than a copy that went stale.
- Delegating a skill: write `Use the skill: /name <args>` and no manual steps.
