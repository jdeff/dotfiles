---
name: dispatch
description: Hand work to a Herdr worktree agent — the host check, the dispatch-prompt contract, and the write→verify→create→confirm sequence. Load before creating a worktree or spawning an agent.
user-invocable: false
allowed-tools: Bash, Write
---

Creating a worktree opens it as its own space under the source repo, copies the
repo's untracked files, then lays out Claude + a shell. A Claude that finds a
dispatch prompt for its branch launches with it as its first message; one that finds
none starts **bare** — no prompt, no work, and no error anywhere.

## Host

Two Herdrs run worktree agents, and each has its own CLI; neither can see the
other's spaces. Settle the **host** first — every herdr command in these skills
belongs to one of them:

| Host | Test | Creates worktrees with |
|---|---|---|
| **TUI** | `test "${HERDR_ENV:-}" = 1` | `herdr worktree create`; the `jdeff.flow` plugin (`herdr plugin list`) runs on `worktree.created` and consumes the prompt |
| **Desktop** (Herdr.app on herdr-core) | `test -n "${HC_TERMINAL_ID:-}"` | `~/.config/herdr/scripts/hc-worktree-create.sh`, which consumes the prompt itself |

Run the TUI test first: the TUI running inside a Desktop terminal is the TUI. If
neither passes, say so and stop.

## Confirm before creating

A worktree means a new branch, a new space, and a running agent. Unless the user
invoked a dispatch skill by slash command, or has already asked for parallel or
background work, list what you would create and get a yes first.

## The contract

The prompt goes to `~/.herdr/dispatch/<slug>.md`, where slug is the branch run
through `tr -c '[:alnum:]' '-'` — the TUI's layout script and the Desktop create
script use the identical transform, and delete the file when the agent launches
with it.

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
# TUI
herdr worktree create --cwd "<repo-root>" --branch "$branch" --no-focus
# Desktop: prints {space, tab, terminal, pane, path}; keep `terminal`, it is the agent
~/.config/herdr/scripts/hc-worktree-create.sh --cwd "<repo-root>" --branch "$branch" --no-focus
```

**3. Confirm each prompt was consumed.** A file still on disk means a bare agent.

```bash
sleep 3; [ -e "$f" ] && echo "BARE — $branch" || echo "consumed"
```

This is the authoritative check. Agent status is not: a fast agent is already `idle`
when you look, so `idle` cannot separate bare from finished. Report a bare agent as a
failure. On Desktop a failed create exits non-zero and leaves the file, so the check
reads the same.

## Flags

Both create commands take these:

- `--cwd <path>` — the repo to branch from. Same repo: `git rev-parse --show-toplevel`;
  cross-project: that repo's absolute path. Never `cd`.
- `--base <ref>` — branch from `<ref>` instead of the repo's current HEAD.
- `--branch <name>` — an existing name checks out, a new name creates.
- `--focus` / `--no-focus` — `--no-focus` keeps you where you are. Always use it for
  more than one worktree. Desktop defaults to `--no-focus`.

## Prompt rules

- Self-contained. The agent cannot see your conversation; include referenced context
  verbatim.
- Relative paths only — each worktree has its own root.
- Thin beats thorough. Point at the source of truth (a ticket, a spec file) so the
  agent reads the current version rather than a copy that went stale.
- Delegating a skill: write `Use the skill: /name <args>` and no manual steps.
