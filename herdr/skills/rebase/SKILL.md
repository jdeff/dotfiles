---
name: rebase
description: Rebase the current branch — or its whole stack — onto the freshly fetched upstream base, then re-evaluate the branch's changes against what landed.
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Bash, Glob, Grep, AskUserQuestion
---

**Arguments:** `$ARGUMENTS`

Bring the current branch up to date with the **latest** base — always fetched,
always the remote copy — and then prove its changes still make sense on top of
what landed underneath them. A clean rebase is only half the job: upstream can
rename, remove, or re-implement what this branch relies on without a single
textual conflict.

## Step 1: Resolve the target

The target is a remote-tracking ref, fetched fresh:

- No argument → the base's upstream. The base is whatever the repo's **main**
  working tree has checked out (the first entry of `git worktree list`),
  defaulting to `main`; its upstream is `origin/main` unless configured
  otherwise.
- `branch` → `origin/branch`
- `remote/branch` → as given

```bash
main_root=$(git worktree list --porcelain | awk '/^worktree /{print $2; exit}')
base=$(git -C "$main_root" rev-parse --abbrev-ref HEAD)
target=$(git -C "$main_root" rev-parse --abbrev-ref "$base@{upstream}" 2>/dev/null || echo "origin/$base")
git fetch "${target%%/*}"
```

Done when `git rev-parse --verify "$target"` resolves. The local base is only a
convenience: when it is strictly behind `$target`
(`git rev-list --left-right --count "$base...$target"` prints `0<TAB>n`) and
the main working tree is clean, fast-forward it with
`git -C "$main_root" merge --ff-only "$target"`; otherwise leave it alone and
note why for the report.

## Step 2: Prepare the branch

Done when all three hold:

- No rebase is already in progress (`git status` says so). If one is, stop and
  ask whether to continue it or abort it.
- The working tree is clean (`git status --porcelain` empty). Otherwise stop
  and ask, listing what is there: **commit it**, **stash it** (and pop it after
  step 4), or **abort**.
- The pre-rebase state is recorded — step 4 reads it, and it is the way back:

```bash
old_head=$(git rev-parse HEAD)
old_base=$(git merge-base HEAD "$target")
```

## Step 3: Rebase

**A stack.** If `gh stack view --json` (always `--json`) lists the current
branch, the stack moves as one — rebasing a single layer strands the ones above
it. The stack's `trunk` is its target: if `origin/<trunk>` isn't `$target`,
ask before going on. Record every layer's `head` from that JSON, then:

```bash
gh stack rebase
```

It fetches the trunk and cascades each layer onto its updated parent, replaying
correctly over layers whose PRs already merged. Exit code **3** is a conflict:
resolve it (below), `git add` the files, `gh stack rebase --continue`, and repeat.
A layer checked out in another worktree can't be moved from here; report it and
`gh stack rebase --abort`. The gh-stack skill has the rest.

**A single branch.**

```bash
git rebase "$target"
```

**Conflicts, either way.** Understand the target's side before touching the
file: `git log -p -n 3 "$target" -- <file>` shows why it changed. Resolve so
both upstream's intent and this branch's intent survive, stage, continue. When
the two intents genuinely compete, ask. Every commit dropped as already
upstream means that piece of the work has landed — note it for the report.

Done when no rebase is in progress and `git merge-base --is-ancestor "$target" HEAD`
exits 0 (for a stack, on the bottom unmerged layer).

## Step 4: Re-evaluate against what landed

The upstream delta is `$old_base..$target`: every commit that landed underneath
the branch. Read it against the branch's own changes (`$target..HEAD`; for a
stack, each layer against its parent):

```bash
git log --oneline "$old_base..$target"
git diff --stat "$old_base..$target"
git diff --name-only "$target..HEAD"
```

Hunt for **semantic conflicts** — breakage no conflict marker shows:

- An API, column, route, type, or config key the branch uses was renamed,
  removed, or re-signatured upstream. Grep the branch's diff for each symbol
  the delta touched.
- Upstream already did some of the branch's work, or did it differently — the
  branch may now duplicate or contradict it.
- Ordering collisions: migration timestamps, schema dumps, lockfiles, generated
  files that need regenerating rather than merging.
- Tests or fixtures upstream changed that the branch's code or tests lean on.

Then run the project's checks for what the branch touches — its tests, lint,
and type-check — so the verdict rests on the code, not on reading it.

Done when every upstream commit that touches a file or symbol the branch uses
is accounted for — fine, fixed, or raised — and the checks have run.

Fix what follows mechanically from upstream's change (a rename, a new required
argument, a regenerated file), committing on the layer the fix belongs to; in a
stack, `gh stack rebase --upstack` afterwards carries it up. Anything that
changes what the branch *does* — a duplicated feature, a contradicted design,
a failing test whose right answer is a judgement call — goes in the report as
a question, not a fix.

## Step 5: Push

Push without asking when the branch has an open PR and the work is clean:
the rebase is finished, any stash is popped, the checks pass, and step 4 left
nothing awaiting a decision. Otherwise push nothing, and offer the command in
the report.

- **Open PR:** `gh pr view --json state -q .state` prints `OPEN`; for a stack,
  any unmerged layer has one.
- **Nothing to lose remotely:** `--force-with-lease` checks against the
  remote-tracking ref, which the fetch just refreshed — so it can't catch a
  commit someone pushed that this branch never had. For each branch pushed,
  `git merge-base --is-ancestor "origin/<branch>" <its pre-rebase head>` must
  exit 0 (or the remote branch must not exist); if not, stop and ask.

Then push: `git push --force-with-lease` for a single branch, `gh stack push`
for a stack (it pushes every unmerged layer atomically with
`--force-with-lease`).

## Step 6: Report

Report: the target and the upstream delta (commit count, and the ones that
mattered), the local base before and after, each branch or layer rebased, how
each conflict was resolved, commits dropped as already upstream, the semantic
findings with what was fixed and what needs a decision, the check results,
what was pushed (or why not, with the command), and the way back
(`git reset --hard "$old_head"`, or the recorded layer heads).
