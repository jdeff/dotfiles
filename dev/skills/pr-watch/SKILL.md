---
name: pr-watch
description: Watch an open PR or stack — fix mechanical CI failures, rebase onto a moved base, work through review comments, and request reviewers once the author says it's ready. Use after opening a PR, or when asked to keep an eye on CI, comments, or a stack going stale.
allowed-tools: Bash, Read, Edit, Write, Grep, Glob
---

Watch a PR or stack and keep it healthy. Run from the worktree holding the branches —
a fix has to happen somewhere.

Resolve the stack once with `gh stack view --json` (never without `--json`), and work
bottom to top.

## Two phases, one gate

**Draft** — yours to shape. **Ready** — other people's time. The author moves between
them; you never do. Do not run `gh pr ready`, and do not request a reviewer, until
they say so in this conversation.

## Each pass

**1. CI** — `gh pr checks <n>` per PR.

| failure | do |
|---|---|
| lint, formatting, annotations, generated files | fix, commit, push |
| a failing spec, or anything behavioural | report and stop |
| unclear which | treat as behavioural |

Mechanical means the fix is determined by the tool's own output. If you'd have to
decide what the code *should* do, it isn't mechanical.

**2. The base moved** — `gh stack view --json` reports `needsRebase` and `isMerged`
per branch, so check before acting rather than syncing every pass.

`gh stack sync` does fetch, rebase, push, and PR-state sync in one; add `--prune` to
drop branches whose PRs merged. On conflict it exits **3** and restores every branch
to its pre-rebase state, so it's safe to attempt unattended. Exit 3 → report and stop;
don't hand-resolve.

**3. Comments.** Separate them by author against `github_handle` in
`~/.config/dev/workspace.toml` (see the `workspace` skill):

- **The author's own comments, while draft** — a work queue. Address them, reply
  saying what changed, resolve the thread.
- **Anyone else's** — use the `pr-feedback` skill. Report what they said and what you
  propose; push nothing behavioural without a yes.

Inline threads don't come back from `gh pr view`. Use both:

```bash
gh pr view <n> --json comments,reviews
gh api repos/{owner}/{repo}/pulls/<n>/comments
```

**4. Report** — per PR: checks, unresolved comments, whether it's behind its base, and
what you changed. Say plainly when nothing happened.

## When the author says it's ready

Ask which PRs, if it's a stack — the bottom alone is usually right, since the ones
above rebase as each merges, and three dependent PRs arriving at once is a worse
review experience.

```bash
gh pr ready <n>
gh pr edit <n> --add-reviewer <github_team>          # from the team's workspace.toml entry
```

`github_team` may be absent (solo repos); then ask who, rather than guessing. Whether
the request round-robins to one person is a GitHub team setting, not something you
control here.

## Cadence

Under `/loop <interval> /pr-watch <n>` for recurring passes. CI here takes a few
minutes, so intervals under ~5m mostly re-read the same pending checks. Stop looping
once everything is green, quiet, and the author has what they need.
