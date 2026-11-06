---
name: worktree-retire
description: Retire a Herdr worktree once the branch's fate is settled — release the muster seat, drop the dispatch prompt, remove the checkout and its space, optionally delete the branch. Load as the last step of a skill that ends a worktree.
user-invocable: false
allowed-tools: Bash, Read
---

The caller has already settled what happens to the branch's work and hands over:

- **branch mode** — `keep` (the base contains the branch, or the user wants it)
  or `delete` (the user chose to throw the work away)
- **`--keep`** — whether the checkout and its space stay
- **its report** — which goes out before the checkout does

Run from inside the worktree being retired. Capture these first; the checkout
and the pane go away at the end:

```bash
branch=$(git branch --show-current)
main_root=$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')
```

In the main working tree (`$PWD` is `$main_root`) there is nothing to retire:
stop and say so.

## Step 1: Release what the checkout holds

Anything running from the checkout or pinned by it goes first — and only what
this checkout holds.

If the repo is muster-managed, run `NO_COLOR=1 muster status` **now**, not from
memory: the seat changes hands between turns. `occupant=<this branch>` →
`muster down`. Any other occupant, or `(not running)` → leave it; the seat is
theirs. The `use:` pins in this worktree's `.muster.yaml` vanish with the
checkout, which is the point. The muster skill has the seat rules.

Stop anything else started from this directory: a dev server by hand, a
watcher, a background job.

## Step 2: Drop the dispatch prompt

Unless `--keep` was passed, delete the prompt a dispatched worktree left outside
its checkout (the dispatch skill's slug transform):

```bash
rm -f "$HOME/.herdr/dispatch/$(printf '%s' "$branch" | tr -c '[:alnum:]' '-').md"
```

## Step 3: Report

Removing the space closes the pane you are running in, so report now: the
caller's report, then the seat (released, someone else's, or not held), the
dispatch prompt (deleted, kept, or none), and what step 4 is about to remove.

## Step 4: Remove

With `--keep`, remove nothing — and in mode `delete`, say the branch stays too,
since a checked-out branch can't be deleted.

Otherwise this is one shell command, the last action. Files a `.worktree-files`
manifest copied in (`.env.local` and the like) live in the checkout and go with
it; its `link` entries are symlinks, and removing one leaves the main checkout's
file alone. Those untracked files make a plain remove refuse, which is why
`--force` appears below. `herdr worktree remove` never touches the branch.

- **Mode `keep`:**

  ```bash
  herdr worktree remove --workspace "$HERDR_WORKSPACE_ID"
  ```

  If it refuses over untracked files, re-run with `--force` only when they are
  ones the caller already accounted for (manifest copies, build output);
  anything else goes back to the user.

- **Mode `delete`:** the user has confirmed the loss. The branch deletion rides
  in the same command because nothing runs after the remove, and it must follow
  the remove because a checked-out branch can't be deleted:

  ```bash
  herdr worktree remove --workspace "$HERDR_WORKSPACE_ID" --force \
    && git -C "$main_root" branch -D "$branch"
  ```

`$HERDR_WORKSPACE_ID` is injected into every Herdr-managed pane. If it is unset
(not running inside Herdr), substitute `git -C "$main_root" worktree remove
[--force] "$PWD"` for the herdr command, and tell the user any space for it is
theirs to close.
