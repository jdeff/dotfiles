---
name: open-pr
description: Open a pull request, or fill in the descriptions across a stack of them, from the repo's own PR template and each layer's diff. Use after committing work that should become a PR.
allowed-tools: Read, Bash, Glob, Grep
---

## The repo's template is the shape

Fill in `.github/pull_request_template.md` (or `PULL_REQUEST_TEMPLATE.md`) where the
repo has one — including any `Relates to ___` line, which takes the ticket URL — and
tick a checkbox only when you can say what backs it. Substitute this only where no
template exists:

```markdown
## Summary
[1-2 sentences: what this PR does and why]

## Changes
- [key change]

## Testing
[how you verified it]
```

Ground every claim in the diff. The reader wasn't in your conversation, and a number
they can't verify is worse than no number.

## Stacked PRs

`gh stack view --json` first (always `--json`). A branch in a stack makes the whole
stack the unit of work.

`gh stack submit --auto` generates **titles only**, leaving every body as the unfilled
template — so submitting is the start:

```bash
gh stack submit --auto            # drafts with correct bases
gh stack view --json              # PR numbers, bottom to top
```

Fill each body from **that layer's own diff** (`gh pr diff <n>`). Each PR is reviewed
alone, so describe its own change and what the reader can assume already landed.

Preserve automation-managed blocks when editing an existing body — anything between
markers such as `<!-- review-app-url -->`. Read the current body, replace your part,
keep the rest, then `gh pr edit <n> --body-file <file>`.

## Single PR

`gh pr create --web` opens the browser rather than creating the PR, so it gets seen
before it exists. Title under 72 characters.

## Stop at draft

Open PRs as drafts and report their numbers. The ready-for-review decision is the
author's — it pings people, and the author reviews their own work first.

`pr-watch` takes it from there: CI, comments, rebasing onto a moved base.
