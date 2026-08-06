---
name: workspace
description: Resolve a ticket key, team, or org to its repos, muster project, and git branch name. Use whenever a bare ticket key like ABC-123 appears, or the question is "which repo does this belong to", "what team owns this", "what should the branch be called", or a Linear issue needs to be located.
allowed-tools: Bash, Read
---

# workspace — resolving a ticket key to a place to work

The map lives at `~/.config/dev/workspace.toml` (work-specific and untracked —
seeded from `~/dotfiles/dev/workspace.toml.example`). Read it; don't guess from
memory, and don't infer a team from a repo name.

## Resolution chain

```
ABC-123
  → [teams.*] where linear_key == "ABC"   → that team
  → .org                                   → [orgs.<org>].name
  → .muster_project                         → e.g. "acme-app"
  → muster projects --json                 → .projects[] | select(.project == …) | .repos
```

**Repos come from muster, always.** `workspace.toml` names the muster project and
stops there. Use `muster projects --json`, which returns absolute expanded paths;
it's read-only and takes no lock. Do not read muster's `config.yaml` — see the
`muster` skill.

If a ticket doesn't say which repo it touches, `default_repo` is the starting
point, not the answer — a full-stack ticket usually needs both repos. Decide from
the ticket's actual content.

## Branch names

Prefer the issue's **own** `gitBranchName` from Linear, which yields
`<user>/<key>-<number>-<slug>`. It matches what the rest of the team's branches
look like, and it's what Linear matches against to auto-link a PR to its issue.
`branch_pattern` in the toml is a fallback for when you can't reach Linear.

Consequence worth remembering: because Linear links by branch name, getting the
branch right *is* the ticket↔PR integration. A hand-made branch name silently
breaks it.

## Reaching Linear

**One connection serves one workspace**, so query the org's own server. Resolve the
key to its org, read that org's `linear_mcp`, and use that server's tools
(`mcp__<linear_mcp>__*`). Never pick a Linear server by whichever one is listed
first.

Getting this wrong is not always loud. A missing team gives "Could not find
referenced Team" — the same symptom as a typo'd key, so don't report it as one. But
two workspaces can each have a team with the same prefix, and then the wrong server
returns a real, plausible, wrong ticket. `list_teams` returns the connected
workspace's teams; use it to confirm when unsure.

If the org's server isn't present, or no Linear tools are, the machine isn't
bootstrapped: say so and point at `~/dotfiles/dev/README.md`. Never guess a ticket's
contents from its key.

## What does not belong in workspace.toml

- **Repo lists** — muster owns them (above).
- **Secrets** — `~/.zshenv.local` / keychain.
- **Repo conventions** (test commands, framework patterns) — each repo's own
  `AGENTS.md` / `CLAUDE.md`, which is also where teammates can see them.
- **Team norms** teammates should share (definition of done, PR hygiene) — that
  repo's `.claude/skills/`, not this machine's dotfiles. Skills tracked in a repo
  travel into every worktree of it; anything here reaches only me.
