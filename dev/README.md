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

Preferred — connect Linear as a **claude.ai connector** (`/mcp` inside Claude
Code). Account-level, so it resolves in every cwd and a new machine inherits it
with no setup.

Fallback, if Linear isn't offered as a connector:

```sh
claude mcp add --scope user --transport http linear https://mcp.linear.app/mcp
```

Either way, drop any per-project Linear entries afterwards so the tool name is the
same everywhere:

```sh
claude mcp remove <name>   # run from each repo that has its own Linear entry;
                           # `claude mcp list` there shows what's registered
```

Caveat: claude.ai-authenticated servers can be missing in headless or cron runs.
If ticket work ever needs to run unattended, a small GraphQL client reading
`LINEAR_API_KEY` from `~/.zshenv.local` is the portable alternative.
