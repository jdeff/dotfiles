# No multiplexer: worktree-create refuses before touching git, and there is no
# session to close.

host_open() {
  echo "not inside Herdr or Rex: no session to open an agent in" >&2
  return 1
}

host_close_session() {
  echo "not inside Herdr or Rex: no session to close" >&2
}
