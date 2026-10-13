---
name: ticket-close
description: Close the Linear tickets a landed branch completes — filter candidate keys, resolve each, gate on remaining work, move it to done. Load after a branch lands, locally or upstream.
user-invocable: false
allowed-tools: Bash, Read, AskUserQuestion
---

The caller has landed a branch and hands over its **candidates**: ticket keys found
in the branch name (`jdeff/mg-123` → `MG-123`) and in the text that describes the
work — commit messages, and the PR's title and body when there is a PR. Match keys
case-insensitively and uppercase them.

## Filter

Keep only keys whose prefix is a team's `linear_key` in `workspace.toml` — that drops
look-alikes such as `UTF-8`. No candidates left → say so in the report and stop.

## Resolve

Resolve each key through the `workspace` skill: it names the org's Linear MCP server,
and the wrong server returns a plausible wrong ticket. Fetch the issue with its
status, attachments, and sub-issues.

## Gate

Close a ticket only when all three hold:

- **Still open.** Its status is not of type `completed` or `canceled` — those are
  skipped and reported. After a PR merge Linear's GitHub integration often got
  there first; that is the normal case, not a failure.
- **Nothing else outstanding.** No other branch for the key with work not on the
  base (`git branch -a --list "*<key-lower>*"` — a ticket with several PRs carries
  suffixed branches like `jdeff/mg-123-2`), no open GitHub PR attached to it, and no
  sub-issue outside `completed`/`canceled`.
- **This branch completes it.** A key in the branch name, or after "fixes",
  "closes", or "resolves", does. One that only appears as a reference ("see
  MG-120", "part of MG-120") does not.

When any is in doubt, ask with the evidence rather than guess; a ticket closed early
drops out of everyone's view.

## Close

Move it to the team's `completed` status (`list_issue_statuses` — the name varies by
team, usually `Done`) and comment where it landed: the branch and merge commit, plus
the PR link when there is one.

## Report

Each candidate: closed, already closed, or left open and why.
