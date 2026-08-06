---
name: open-pr
description: Open a pull request, or fill in the descriptions for a stack of them, using the repo's own PR template and the current diff. Use after committing work that should become a PR; invoked directly or by /ticket-work.
allowed-tools: Read, Bash, Glob, Grep
---

## Use the repo's template, not a generic one

If `.github/pull_request_template.md` (or `PULL_REQUEST_TEMPLATE.md`) exists, that is
the shape of the body. Fill its sections in — including any `Relates to ___` line,
which takes the ticket URL — and tick a checkbox only when you can say what backs it.
Only if the repo has no template, use:

```markdown
## Summary
[1-2 sentences: what this PR does and why]

## Changes
- [key change]

## Testing
[how you verified it]
```

Lead with what and why, not how. Ground every claim in the diff — a description is
read by someone who wasn't in your conversation, and an unverifiable number in it is
worse than no number.

## Stacked PRs

Check first: `gh stack view --json` (never without `--json`). If the branch belongs to
a stack, the whole stack is the unit of work.

`gh stack submit --auto` generates **titles only** — it leaves every body as the
unfilled template. So submitting is not the end:

```bash
gh stack submit --auto            # creates/updates the PRs as drafts, correct bases
gh stack view --json              # PR numbers, bottom to top
```

Then fill each body from **that layer's own diff** (`gh pr diff <n>`), not the whole
stack's. Each PR is reviewed alone; describing the stack three times helps nobody.
State each PR's place in the chain and what the reader can assume already landed.

When editing an existing body, **preserve automation-managed blocks** — anything
between markers such as `<!-- review-app-url -->`. Read the current body, replace only
your part, keep the rest:

```bash
gh pr edit <n> --body-file <file>
```

## Single PR

```bash
git status                        # commit anything outstanding first
git push -u origin HEAD
gh pr create --web --title "<title, max 72 chars>" --body "<body>"
```

`--web` opens the browser rather than creating it, so you see it before it exists.

## Leave it to the human

Open PRs as **drafts** and stop. Do not mark ready for review and do not request
reviewers — that pings people, and the author reviews their own work first. Report the
PR numbers and the command they'd run.

To keep watching a PR or stack afterwards — CI, comments, rebasing onto a moved base —
use the `pr-watch` skill.
