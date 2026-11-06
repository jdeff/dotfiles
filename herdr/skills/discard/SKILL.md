---
name: discard
description: Throw away the current worktree without merging — show what would be lost, confirm, then remove the checkout, its space, and the branch.
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
---

**Arguments:** `$ARGUMENTS`

Check the arguments for flags:

- `--keep-branch`, `-b` → remove the checkout and its space but keep the branch

Strip all flags from arguments.

The branch was an experiment, a test, or exploration, and it ends here
unmerged. `/merge` and `/merged` retire a branch whose work landed; this one
retires a branch whose work is being thrown away, so the whole job is making
that loss visible before it happens.

## Step 1: Inventory the loss

This skill needs a non-main worktree; in the main tree, stop and say so.

The base branch is whatever the repo's **main** working tree has checked out
(the first entry of `git worktree list`); default to `main` if that yields
nothing usable:

```bash
main_root=$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')
base=$(git -C "$main_root" rev-parse --abbrev-ref HEAD)
branch=$(git branch --show-current)

git status --porcelain                                  # uncommitted + untracked
git log --oneline "$base..HEAD"                         # commits not on the base
git ls-remote --heads origin "$branch"                  # pushed?
gh pr list --state open --head "$branch" --json number,url,title
```

Also note the Linear ticket key in the branch name, if any (`jdeff/abc-123` →
`ABC-123`).

Done when every item above has an answer: each uncommitted file, each commit
the base lacks, the remote branch (absent, or which of the local commits it
lacks), and the open PR or its absence.

## Step 2: Confirm

Ask once, laying out the inventory: the files, the commits (count plus the
one-liners), the remote branch, the PR, the ticket. When the inventory is empty
— clean tree, no commits beyond the base, nothing remote — say so in the
question; it is still the user's call.

- **Discard everything** — checkout, space, and branch (unless `--keep-branch`)
- **Keep the branch, drop the checkout**
- **Abort**

When a remote branch or open PR exists, ask a second question alongside: close
the PR and delete the remote branch, or leave them. Abort ends the skill with
nothing touched.

## Step 3: Remote cleanup

Only if the user chose it in step 2:

```bash
gh pr close <number> --comment "Discarded unmerged."
git push origin --delete "$branch"
```

## Step 4: Retire

Hand off to the `worktree-retire` skill — branch mode `delete` for "Discard
everything", `keep` for "Keep the branch" or `--keep-branch` (the user confirmed
the uncommitted files in step 2, so they count as accounted for). Its report leads
with this one: what was thrown away (files and commits, from step 1), the remote
branch and PR and what happened to each, and the ticket — left as it is, since
an abandoned branch doesn't finish it; name it so the user can update it.
