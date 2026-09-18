---
name: merged
description: Retire the current worktree after its PR merged upstream — confirm the merge, fast-forward the base, verify nothing was left behind, release the muster seat, remove the checkout.
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
---

**Arguments:** `$ARGUMENTS`

Check the arguments for flags:

- `--keep`, `-k` → keep the worktree checkout and its Herdr space

Strip all flags from arguments.

The pull request for the current branch has merged upstream. `/merge` lands a
branch locally; this skill retires one that already landed: prove the merge,
account for every change on the branch, bring the local base up to date,
release what the checkout holds, and remove it.

## Step 1: Account for uncommitted work

Anything uncommitted is about to lose its home:

```bash
git status --porcelain
```

This step is done when that is empty. Otherwise stop and ask, listing what is
there, with these choices:

- **Carry it to a follow-up branch** off the base — a new branch, not this one
- **Discard it**
- **Abort**

## Step 2: Confirm the merge

```bash
gh pr view --json number,url,state,mergedAt,mergeCommit,baseRefName
```

(If the lookup fails because GitHub already deleted the branch, find the number
with `gh pr list --state all --head "$(git branch --show-current)"`.)

Done when `state` is `MERGED`; keep `baseRefName` and `mergeCommit.oid` for
step 4. Anything else ends the skill with a report: `OPEN` means nothing has
landed — `/merge` lands it locally and `pr-watch` minds it; `CLOSED` or no PR
means the branch's fate is the user's call.

If `gh stack view --json` shows the branch in a stack, this skill retires only
this layer; the layers above still need `gh stack sync` (the gh-stack skill).
Say so in the report and carry on.

## Step 3: Sync the base

The base branch is whatever the repo's **main** working tree has checked out
(the first entry of `git worktree list` is always the main tree); default to
`main` if that yields nothing usable.

```bash
main_root=$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')
base=$(git -C "$main_root" rev-parse --abbrev-ref HEAD)
upstream=$(git -C "$main_root" rev-parse --abbrev-ref "$base@{upstream}")   # e.g. origin/main
git fetch "${upstream%%/*}"
git rev-list --left-right --count "$base...$upstream"                      # ahead<TAB>behind
```

A base that is strictly behind is the expected state: the merge we are here
for is what it is missing. When it is strictly behind and the main working
tree is clean (`git -C "$main_root" status --porcelain` empty), fast-forward it:

```bash
git -C "$main_root" merge --ff-only "$upstream"
```

Done when `git rev-parse "$base" "$upstream"` prints one hash twice. A base
with no upstream, an ahead or diverged base, or a dirty main working tree is
the user's call: report the counts and ask, offering to **verify against
`$upstream` instead** (leave the local base alone and read `$upstream`
wherever step 4 says `$base`) or to **abort**.

## Step 4: Verify it landed

Two facts, both checkable:

1. The merge commit is on the base:
   `git merge-base --is-ancestor "$merge_commit" "$base"` exits 0.
2. The branch adds nothing beyond the base. `git rebase "$base"` drops every
   commit — as already upstream after a merge or rebase merge, as empty after
   a squash merge — and afterwards `git rev-parse HEAD "$base"` prints one
   hash twice.

Commits that survive the rebase did not land (never pushed, or pushed after
the merge). List them with `git log --oneline "$base"..HEAD` and ask, with the
step 1 choices. A conflict during the rebase says the same thing about a base
that has since moved: `git rebase --abort`, list the branch's commits, and ask.

Also note whether the remote branch still exists
(`git ls-remote --heads origin "$(git branch --show-current)"`); GitHub
usually deletes it on merge. Report it; deleting it is not this skill's job.

## Step 5: Release what the checkout holds

The checkout is about to disappear, so anything running from it or pinned by
it goes first — and only what this checkout holds.

If the repo is muster-managed, run `NO_COLOR=1 muster status` **now**, not from
memory: the seat changes hands between turns. `occupant=<this branch>` →
`muster down`. Any other occupant, or `(not running)` → leave it; the seat is
theirs. The `use:` pins in this worktree's `.muster.yaml` vanish with the
checkout, which is the point. The muster skill has the seat rules.

Stop anything else you started from this directory: a dev server by hand, a
watcher, a background job.

## Step 6: Clean up

Unless `--keep` was passed, remove the worktree checkout and its Herdr space.
The branch stays; it is fully contained in the base, so `git branch -d` is
safe whenever the user wants it gone (`gh stack sync --prune` does the same
for a stacked branch):

```bash
herdr worktree remove --workspace "$HERDR_WORKSPACE_ID"
```

`$HERDR_WORKSPACE_ID` is injected into every Herdr-managed pane. If it is unset
(not running inside Herdr), skip this step and tell the user to remove the
worktree themselves.

Removing the space closes the pane you are running in, so make this the last
action. Report first: the PR number and merge commit, the base before and
after, the verification result, the remote branch, the seat, and whether the
checkout was removed or kept.
