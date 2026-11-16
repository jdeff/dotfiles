---
name: dispatch
description: Hand work to a worktree agent — the dispatch-prompt contract, and the write→verify→create→open→confirm sequence. Load before creating a worktree or spawning an agent.
user-invocable: false
allowed-tools: Bash, Write, Read
---

A dispatched agent is Claude running in its own worktree and its own multiplexer
session, launched with a **dispatch prompt** as its first message. One launched
without its prompt starts **bare** — no work, and no error anywhere.

## Host

The session is opened with your multiplexer's own commands. Read the matching file
now; it also covers the address line for a report back:

- `REX_SESSION` set → [rex.md](rex.md)
- `HC_TERMINAL_ID` set → [herdr.md](herdr.md)
- neither → say dispatch needs a Herdr or Rex terminal, and stop

Shell variables don't survive between Bash calls: run each block whole, or carry
values forward by hand.

## Confirm before creating

A worktree means a new branch, a new session, and a running agent. Unless the user
invoked a dispatch skill by slash command, or has already asked for parallel or
background work, list what you would create and get a yes first.

## The contract

The prompt lives at `~/.local/state/dispatch/<slug>.md`, slug = the branch through
`tr -c '[:alnum:]' '-'`. The open command in the host file launches Claude with it and
deletes it once the session exists, so a file still on disk means a bare agent.

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

**1. Write each prompt.** Done when `wc -c` prints a non-zero count for every file.

```bash
mkdir -p ~/.local/state/dispatch
branch="<branch>"
f="$HOME/.local/state/dispatch/$(printf '%s' "$branch" | tr -c '[:alnum:]' '-').md"
cat > "$f" << 'EOF'
<prompt>
EOF
wc -c "$f"
```

**2. Create each worktree.** Done when every call printed a path.

```bash
wt=$(worktree-create --cwd "<repo-root>" --branch "$branch" [--base <ref>])
```

Hold the path in `wt`: zsh ties `path` to `PATH`, and assigning it breaks every
command after.

- `--cwd` — the repo to branch from: `git rev-parse --show-toplevel` for this one, an
  absolute path for another. Pass it rather than `cd`-ing.
- `--branch` — an existing name checks out, a new name creates.
- `--base <ref>` — start a new branch from `<ref>` instead of HEAD.

**3. Open each session** with the host file's open command. Done when each one
printed its session and agent — record them as you go; they are its address
afterwards. Stay where you are, except for a single dispatch the user will work in
next.

**4. Confirm every prompt was consumed.** Done when no prompt file remains.

```bash
sleep 3; [ -e "$f" ] && echo "BARE — $branch" || echo "consumed"
```

This is the authoritative check. Agent status can't separate bare from finished — a
fast agent is already `idle` when you look. Report a bare agent as a failure.

## Prompt rules

- Self-contained. The agent cannot see your conversation; include referenced context
  verbatim.
- Relative paths only — each worktree has its own root.
- Thin beats thorough. Point at the source of truth (a ticket, a spec file) so the
  agent reads the current version rather than a copy that went stale.
- Delegating a skill: write `Use the skill: /name <args>` and no manual steps.
- A report back is opt-in: say when you want one ("message me when the PR is up")
  and end the prompt with the host file's address line.
