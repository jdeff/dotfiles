# Cross-repo work

The multi-repo branch of [`SKILL.md`](SKILL.md): how to learn what a project
contains, and how to point one repo at a sibling's worktree. Rules 0–3 in
`SKILL.md` still apply.

## Resolving projects and repos

`muster projects --json` answers which projects exist, which repos are in them,
and what's live:

```json
{
  "config": "/Users/you/.config/muster/config.yaml",
  "service_file": ".muster.yaml",
  "projects": [
    { "project": "web", "session": "muster-web",
      "repos": ["/Users/you/src/acme/api", "/Users/you/src/acme/client"],
      "occupant": "demo", "busy": false }
  ]
}
```

`repos` are absolute and `~`-expanded, `session` and `service_file` have their
defaults applied, and `occupant` is `null` when idle. `busy: true` means a
mutation is in flight, so a mutating command will be refused until it finishes.

Ask muster rather than reading `config.yaml`: `$MUSTER_CONFIG` can move that file,
so the default path may not be the one muster loaded — the JSON echoes back the
file it actually used. The raw YAML also stores repo paths unexpanded and omits
`session` / `service_file` whenever they fall back to defaults, so parsing it
hands you a literal `~` and missing values.

For the **services** a repo defines, read the `service_file` named above from
inside the relevant worktree — that part is still a file.

## Pinning a sibling worktree: assert before, verify after

In a multi-repo project, branch names for the *same* work often differ per repo,
and muster resolves each repo independently:

```
`use:` pin  →  the occupant's own worktree  →  main
```

So a sibling repo whose branch name doesn't match falls back to `main` and
`muster up` still reports success. Silence is the failure mode.

Pin a sibling worktree only where the user, the task prompt, or your own
orchestration explicitly established the pairing. If you suspect a sibling
dependency but weren't told, ask.

**Assert before.** State the intended mapping before bringing anything up:

> Bringing up `myproj`: `client` → `add-search-filters`, `api` →
> `search-index-endpoint` (pinned).

**Then pick a mechanism.**

*Durable* — a `use:` pin in the **occupant worktree's own** `.muster.yaml`.
Survives `up`/`restart` and outranks a same-named worktree. Use when the
dependency is part of the task:

```yaml
# in the client worktree's .muster.yaml
use:
  api: search-index-endpoint
```

Keys are **repo directory names**, values are **branch names**. Remove the pin once
the dependency merges — it wins permanently otherwise. Check whether
`.muster.yaml` is gitignored in that repo before editing; if it's tracked, the pin
would land in the PR diff, so prefer a swap.

*Ephemeral* — re-point one repo on an already-live stack. No file edit, but
**wiped by the next `muster up`**. Use for a one-off check. Takes a repo **path**
(unlike the pin's dir name):

```sh
muster <project> swap /path/to/repo search-index-endpoint
```

**Verify after.** Re-read the `(using)` column for every service. If a repo landed
on `main` and you didn't intend that, the stack is wrong — say so, don't proceed.

To see what a sibling repo actually has:
`herdr worktree list --cwd <repo> --json`.
