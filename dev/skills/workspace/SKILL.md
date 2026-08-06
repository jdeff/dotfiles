---
name: workspace
description: Resolve a ticket key like ABC-123 to its team, repos, branch name, and the Linear MCP server that can see it. Use whenever a bare ticket key appears, or a Linear issue needs fetching.
allowed-tools: Bash, Read
---

The map is `~/.config/dev/workspace.toml` (work-specific, untracked, seeded from
`~/dotfiles/dev/workspace.toml.example`). Resolve every field from that file — a
repo's name is not evidence of which team owns it.

## Resolution chain

```
ABC-123
  → [teams.*] where linear_key == "ABC"   → that team
  → .org                                   → [orgs.<org>]
  → .muster_project
  → muster projects --json                 → .projects[] | select(.project == …) | .repos
```

**Repos come from muster, always.** `workspace.toml` names the muster project and
stops there. `muster projects --json` returns absolute expanded paths, read-only and
lock-free; muster's `config.yaml` is off-limits (see the `muster` skill).

`default_repo` is where a ticket starts when it names no repo, not where it ends — a
full-stack ticket usually needs both. Decide from the ticket's content.

`github_team`, where a team carries one, is the reviewer to request once the author
says a PR is ready.

## Branch names

Take the issue's own `gitBranchName` from Linear, which yields
`<user>/<key>-<number>-<slug>` and matches the rest of the team's branches.
`branch_pattern` is the fallback when Linear is unreachable, and it takes
`linear_user` from the **org** — the same person has a different Linear username in
each workspace.

Linear links a PR to its issue by finding the **key** in the branch name, so a branch
carrying the key keeps the link. The leading username is convention, and Linear
regenerates it from the current username — read it fresh rather than reusing an old
one.

## Reaching Linear

One connection serves one workspace, so query the org's own server: resolve the key to
its org, read that org's `linear_mcp`, and use that server's tools
(`mcp__<linear_mcp>__*`).

Picking the wrong server is quiet. A missing team gives "Could not find referenced
Team", which reads exactly like a typo'd key; worse, two workspaces can each hold a
team with the same prefix, and the wrong server then returns a real, plausible, wrong
ticket. `list_teams` returns the connected workspace's teams — use it to confirm.

An absent server means the machine isn't bootstrapped: say so and point at
`~/dotfiles/dev/README.md`. A ticket's contents come from Linear, never from its key.
