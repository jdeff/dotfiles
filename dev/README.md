# dev — the work map

`~/.config/dev/workspace.toml` is the org / team / repo map agents resolve a ticket
key through (`ABC-123` → team → org → muster project → repos). The `workspace` skill
under `skills/` is the procedure that reads it.

**The real file is never tracked.** This repo is public, and a work map is team
names, ticket prefixes, and internal repo layout — the same category as the work
tokens in `~/.zshenv.local`. So `install.sh` *seeds* it from
`workspace.toml.example` rather than symlinking it, exactly like
`~/.gitconfig.local`, and `dev/workspace.toml` is gitignored as a backstop.

Consequence: edits to the real file don't ride along to a new machine. That's the
same trade `~/.gitconfig.local` makes — re-fill it from the example, or keep a copy
somewhere private.

The rest of the split is deliberate too: the **facts** are data (several skills need
them), the **procedure** is a tracked skill, and the **repo list** belongs to
neither — muster already owns project → repos, and answers via
`muster projects --json`.

## One-time per-machine bootstrap: Linear

Not done by `install.sh` — same category as `gh auth login` and herdr's plugin
registration. Ticket skills need Linear to resolve in **every** cwd, because
worktrees live under `~/.herdr/worktrees/<repo>/<slug>`, not in the main checkout.
A per-project MCP registration (the default `claude mcp add` scope) does not
follow a worktree there.

Two constraints shape this. Worktrees live under `~/.herdr/worktrees/<repo>/<slug>`,
so a project-scoped registration never reaches them — Linear must be **user-scoped**.
And the official Linear MCP is OAuth-only and **single-workspace per instance**:
reconnecting doesn't switch workspace within an existing auth session, and two
entries pointing at the same URL share one auth context, so renaming the server
doesn't buy you a second workspace.

Linear's documented answer is one `mcp-remote` instance per workspace, each with its
own credential directory. One per org in `workspace.toml`, named to match that org's
`linear_mcp`:

```sh
claude mcp add --scope user linear-<org> \
  -e MCP_REMOTE_CONFIG_DIR="$HOME/.mcp-auth/<workspace-slug>" \
  -- npx -y mcp-remote https://mcp.linear.app/mcp
```

Then `/mcp` in Claude Code to authenticate each, choosing the matching workspace in
the browser. Verify per server with `list_teams` — it returns that workspace's teams.

Needs node on PATH (mise provides it). Credentials land in `~/.mcp-auth/<slug>/`,
not the keychain.

Drop any older Linear entries once the new ones work, so no server can be picked by
accident:

```sh
claude mcp remove <name>   # `claude mcp list` shows what's registered;
                           # per-project entries must be removed from that repo
```
