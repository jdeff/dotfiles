#!/usr/bin/env bash
#
# Build & install the jdeff/workmux fork from source into ~/.local/bin.
#
# Idempotent: clones the fork on first run (adding an `upstream` remote pointing
# at raine/workmux), then builds whatever is checked out. Re-run any time — or
# use the `workmux-update` shell function — to rebuild after pulling changes.
#
# Called by the top-level install.sh after `brew bundle` provides cargo.
#
#   WORKMUX_SRC     where the fork is cloned   (default: ~/src/workmux)
#   WORKMUX_REMOTE  clone URL for the fork     (default: SSH, so it's push-able)
#
set -euo pipefail

WORKMUX_SRC="${WORKMUX_SRC:-$HOME/src/workmux}"
WORKMUX_REMOTE="${WORKMUX_REMOTE:-git@github.com:jdeff/workmux.git}"
WORKMUX_UPSTREAM="https://github.com/raine/workmux.git"

if ! command -v cargo >/dev/null; then
  echo "  !! cargo not found — run 'brew bundle' first (Brewfile has brew 'rust')" >&2
  exit 1
fi

if [[ ! -d "$WORKMUX_SRC/.git" ]]; then
  git clone "$WORKMUX_REMOTE" "$WORKMUX_SRC"
  git -C "$WORKMUX_SRC" remote add upstream "$WORKMUX_UPSTREAM" 2>/dev/null || true
  echo "  clone  $WORKMUX_SRC (+ upstream remote)"
else
  echo "  ok    $WORKMUX_SRC (exists)"
fi

# --root ~/.local lands the binary at ~/.local/bin/workmux, which zprofile
# already puts on PATH. --force overwrites any prior build (this is a rebuild
# workflow). Drop --locked if the repo has no committed Cargo.lock.
cargo install --path "$WORKMUX_SRC" --root "$HOME/.local" --force --locked
echo "  built  workmux -> ~/.local/bin/workmux"
