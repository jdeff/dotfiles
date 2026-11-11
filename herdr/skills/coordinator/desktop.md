# Coordinator reference: Desktop host

Commands for herdr-core's `hc` and Herdr.app's `herdr-app`, used when the
`dispatch` skill's Host check says Desktop. `hc --skill` is the full manual.
**Timeouts are SECONDS** here: `--timeout 3600` is one hour.

## Handles

The create script prints the agent's `terminal` (`t7`): that address is its
handle, valid in every `hc` command. Terminals can't be renamed after launch,
so keep a branch → terminal table as you dispatch. To recover one:

```bash
hc ls --json | jq -r --arg p "$path" '.terminals[] | select(.cwd==$p) | .address'
herdr-app ls    # spaces > tabs > terminals, with pane ids
```

The app started these agents, so they are not your `hc` children:
`hc wait --children` never covers them. Wait on each terminal by address.

## Monitor status

```bash
hc ls                     # every live terminal, with status
hc get t7 --json          # .status = {app, state}; .state = live | finished
```

States are `working`, `blocked`, `idle`, `done`, `error`, or null (no agent
reporting yet, e.g. a trust dialog: read the screen).

## Wait

`hc wait` takes one terminal. It returns `{reason, status, turn}`;
`reason: timeout` is a check-in, not a failure — wait again.

```bash
hc wait t7 --timeout 3600 --json

# Several: background each, then wait
for t in t7 t9 t12; do hc wait "$t" --timeout 7200 --json & done; wait
```

`blocked` and `error` end a wait, so a completion wait already includes them.
An agent passes through `idle` at **turn 0** while starting, before its launch
prompt lands: an agent has started on its work once `turn` is 1 or more, and
an `idle` at turn 0 is still booting — wait again.

## Capture output

```bash
hc read t7 --lines 0      # visible screen only
hc read t7 --lines 50     # screen plus history
```

While an agent is `working`, `blocked` or `error`, a history read returns only
the screen, marked incomplete.

## Send instructions

```bash
hc send t7 "fix the failing tests"
hc send t7 "/commit"
hc send --wait t7 "fix the failing tests" --timeout 1800   # and wait for that turn
hc send --if idle t7 "..."                                 # only if it's idle
```

`send` refuses a `blocked` agent: read its screen and take the decision to the
user. `--force` would answer its dialog for them.

## Run commands

Run tests and builds in a background terminal of your own, in the agent's
worktree, rather than in the agent's pane:

```bash
hc run --bg --name auth-tests --cwd "$path" -- pnpm test
hc wait auth-tests; hc read auth-tests --lines 40; hc rm auth-tests
```

These are your children, invisible in the window, and end when you do.

## Merge & cleanup

```bash
hc send --wait t7 "/merge" --timeout 1800
```

`/merge` retires its own worktree: it removes the checkout and closes the
space, which ends the agent's terminal (`hc get` reports `finished`). Nothing
is left for you to remove. An agent told `/merge --keep` keeps both.

## Fan-out / Fan-in example

```bash
# 1. Write ALL prompt files first (the dispatch skill)
# 2. Create the worktrees, staying put; record each terminal
repo="$(git rev-parse --show-toplevel)"
create=~/.config/herdr/scripts/hc-worktree-create.sh
for b in auth-module api-tests docs-update; do
  printf '%s %s\n' "$b" "$("$create" --cwd "$repo" --branch "$b" | jq -r .terminal)"
done   # auth-module t7 / api-tests t9 / docs-update t12

# 3. Wait for completion (turn >= 1; blocked and error end it too)
for t in t7 t9 t12; do hc wait "$t" --timeout 7200 --json & done; wait

# 4. Review results
hc ls
hc read t7 --lines 50
hc read t9 --lines 50

# 5. Merge successful agents one at a time
hc send --wait t7 "/merge" --timeout 1800
hc send --wait t9 "/merge" --timeout 1800

# 6. Follow up where needed
hc send --wait t12 "also add the API reference section" --timeout 1800
hc send --wait t12 "/merge" --timeout 1800
```
