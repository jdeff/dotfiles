---
name: pr-watch
description: Watch an open PR or stack — mechanical CI fixes, rebasing onto a moved base, comments, and reviewer requests once the author says ready. Use after opening a PR, or when one needs minding.
allowed-tools: Bash, Read, Edit, Write, Grep, Glob
---

Run from the worktree holding the branches — a fix has to land somewhere. Resolve the
stack once with `gh stack view --json` (always `--json`) and work bottom to top.

## Two phases, one gate

**Draft** is yours to shape; **ready** spends other people's time. The author moves a
PR between them, so `gh pr ready` and reviewer requests wait for them to say so here.

## Each pass

**1. CI** — `gh pr checks <n>` per PR.

| failure | do |
|---|---|
| lint, formatting, annotations, generated files | fix, commit, push |
| a failing spec, or anything behavioural | report and stop |
| unclear which | treat as behavioural |

**Mechanical** means the tool's own output determines the fix. Deciding what the code
*should* do puts it in the second row.

**2. The base moved** — `gh stack view --json` reports `needsRebase` and `isMerged`
per branch, so act on those rather than syncing every pass.

`gh stack sync` does fetch, rebase, push, and PR-state sync in one; `--prune` drops
branches whose PRs merged. A conflict exits **3** with every branch restored to its
pre-rebase state, which makes it safe to attempt unattended — and exit 3 is a report,
not a hand-resolve.

**3. Comments.** Split by author against `github_handle` in `workspace.toml` (the
`workspace` skill):

- **The author's own, while draft** — a work queue. Address them, reply with what
  changed, resolve the thread.
- **Anyone else's** — the `pr-feedback` skill. Report what they said and what you
  propose; behavioural changes wait for a yes.

Inline threads need both calls:

```bash
gh pr view <n> --json comments,reviews
gh api repos/{owner}/{repo}/pulls/<n>/comments
```

**4. Report** per PR: checks, unresolved comments, whether it's behind its base, and
what you changed — including when that is nothing.

## When the author says it's ready

For a stack, ask which PRs. The bottom alone is usually right: the ones above rebase as
each merges, and a reviewer meeting three dependent PRs at once reviews all three
worse.

```bash
gh pr ready <n>
gh pr edit <n> --add-reviewer <github_team>    # from the team's workspace.toml entry
```

A team carrying no `github_team` needs the reviewer named by the author. Whether the
request round-robins to one person is a GitHub team setting.

## Cadence

`/loop <interval> /pr-watch <n>` for recurring passes, at an interval longer than the
repo's CI takes — shorter and each pass re-reads the same pending checks. Stop looping
once everything is green, quiet, and the author has what they need.
