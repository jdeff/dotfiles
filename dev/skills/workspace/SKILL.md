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

Build the branch from `branch_pattern` — `<user>/<key>-<number>`, e.g.
`jdeff/mg-123` — not from Linear's `gitBranchName`, whose title slug is noise.
`linear_user` comes from the **org**: the same person has a different Linear username
in each workspace. The key is lowercased, because macOS's case-insensitive filesystem
lets `MG-123` and `mg-123` refs collide.

One branch per ticket per repo. A second PR in the same repo takes a suffix
(`jdeff/mg-123-2`, `jdeff/mg-123-backfill`), never a nested path — git can't hold both
`jdeff/mg-123` and `jdeff/mg-123/api`.

Linear links a PR to its issue by finding the **key** in the branch name, so any of
these keeps the link.

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
