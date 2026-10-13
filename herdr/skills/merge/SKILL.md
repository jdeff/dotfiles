---
name: merge
description: Commit, sync the base, rebase, merge the current branch into its base, and close the Linear tickets it completes.
disable-model-invocation: true
allowed-tools: Read, Bash, Glob, Grep, AskUserQuestion
---

**Arguments:** `$ARGUMENTS`

Check the arguments for flags:

- `--keep`, `-k` → keep the worktree checkout and its Herdr space after merging
- `--no-verify`, `-n` → pass `--no-verify` to `git commit` (skip hooks)

Strip all flags from arguments.

Finish work on the current branch: commit what is staged, bring the base up to
date, rebase onto it, merge into it, close out the Linear tickets the merge
completes, and clean up the worktree.

## Step 1: Commit

If there are staged changes, commit them. Use lowercase, imperative mood, no
conventional commit prefixes. Skip if nothing is staged. Add `--no-verify` only
if that flag was passed.

## Step 2: Sync the base

The base branch is whatever the repo's **main** working tree has checked out
(the first entry of `git worktree list` is always the main tree); default to
`main` if that yields nothing usable. Fetch its upstream and compare:

```bash
main_root=$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')
base=$(git -C "$main_root" rev-parse --abbrev-ref HEAD)
upstream=$(git -C "$main_root" rev-parse --abbrev-ref "$base@{upstream}")   # e.g. origin/main
git fetch "${upstream%%/*}"
git rev-parse "$base" "$upstream"
```

This step is done when both hashes match. Otherwise stop before touching
anything and ask what to do, reporting how the base relates to its upstream
(`git rev-list --left-right --count "$base...$upstream"` gives ahead/behind
counts) with these choices:

- **Fast-forward the base and continue** — offer only when the base is strictly
  behind and the main working tree is clean: `git -C "$main_root" merge --ff-only "$upstream"`
- **Continue against the stale base**
- **Abort**

A base with no upstream configured, an ahead or diverged base, or a dirty main
working tree is the user's call; present the situation and wait.

## Step 3: Rebase

Rebase onto the local base. The merge in step 4 lands in the main working tree,
so the branch must sit on the tip that tree has checked out:

```bash
git rebase "$base"
```

If the rebase drops every commit as already upstream, the branch's work has
already landed; carry on, since the merge will report "Already up to date" and
the worktree still needs cleaning up.

On conflicts, understand the base's side first: run
`git log -p -n 3 "$base" -- <file>` for each conflicting file, resolve so both
the base's changes and this branch's survive, stage the file, and
`git rebase --continue`. Ask for guidance when a conflict is unclear.

## Step 4: Merge

This step needs a non-main worktree; in the main tree there is nothing to merge,
so stop and say so. Otherwise merge the branch into its base, in the main working
tree:

```bash
git -C "$main_root" merge --no-ff "$(git branch --show-current)"
```

If the merge hits conflicts, stop and report that they must be resolved in the
main worktree (print its path). Do not attempt to resolve them from here.

## Step 5: Close out Linear tickets

The merge is local, so nothing reaches GitHub and Linear never sees it land —
no PR merges, and no magic word gets pushed. Closing the tickets is this
skill's job.

**Candidates.** Ticket keys in the branch name (`jdeff/mg-123` → `MG-123`) and
in the messages of the commits just merged:

```bash
git -C "$main_root" log --format=%B HEAD^1..HEAD^2   # the merge commit's branch side
```

An "Already up to date" merge has no merge commit; take the branch's own
commits instead (`git log --format=%B "$base@{upstream}..HEAD"`, or the branch
name alone if that is empty). Match keys case-insensitively and uppercase them.
Keep only keys whose prefix is a team's `linear_key` — that drops look-alikes
such as `UTF-8`. No candidates → say so in the report and move on.

**Resolve each** through the `workspace` skill: it names the org's Linear MCP
server, and the wrong server returns a plausible wrong ticket. Fetch the issue
with its status, attachments, and sub-issues.

**Close it when the merge completes it:**

- Its status is not already of type `completed` or `canceled` — those are
  skipped and reported.
- Nothing else is still open for it: no other branch for the key with unmerged
  work (`git branch -a --list "*<key-lower>*"` — a ticket with several PRs
  carries suffixed branches like `jdeff/mg-123-2`), no open GitHub PR attached
  to it, and no sub-issue outside `completed`/`canceled`.
- A key that only appears in a commit message as a reference ("see MG-120",
  "part of MG-120") is not completed by this branch; one in the branch name or
  after "fixes", "closes", or "resolves" is.

When all three hold, move it to the team's `completed` status
(`list_issue_statuses` — its name varies by team, usually `Done`), and comment
the branch and merge commit. When any is in doubt, ask with the evidence rather
than guess; a ticket closed early drops out of everyone's view.

## Step 6: Clean up

Unless `--keep` was passed, remove the worktree checkout and its Herdr space.
This keeps the branch; only the checkout and the space go away:

```bash
herdr worktree remove --workspace "$HERDR_WORKSPACE_ID"
```

`$HERDR_WORKSPACE_ID` is injected into every Herdr-managed pane. If it is unset
(not running inside Herdr), skip this step and tell the user to remove the
worktree themselves.

Removing the space closes the pane you are running in, so make this the last
action and report before doing it: the merge result, and each candidate ticket
— closed, already closed, or left open and why.

## Interactive alternative

The same flow exists as a keybinding for when you'd rather drive it yourself:
`prefix shift+m` (or the "Merge worktree → base" right-click action on a space)
runs `~/.config/herdr/scripts/worktree-merge.sh`, which prompts at each step but
does not fetch first.
