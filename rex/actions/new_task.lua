-- New Task…: a floating Claude in ~/src that dispatches whatever you type into
-- worktree sessions (/ticket for a ticket key, /worktree otherwise), then closes
-- itself. Its standing instructions are ../new-task.md.

local HOME = os.getenv("HOME")

-- Auto mode's classifier blocks a block close that only the system prompt asks
-- for, so allow the panel's own close command, verbatim as new-task.md gives it,
-- for this Claude alone. The = form matters: the flag is variadic.
local CLOSE_SELF = 'Bash(rex block close -s "$REX_SESSION" "$REX_BLOCK")'

rex.action{
  name = "new_task",
  title = "New Task…",
  description = "Describe work in a floating Claude and dispatch it to worktrees.",
  keywords = "worktree dispatch claude ticket",
  run = function(ctx)
    rex.session.new_layer{
      session_id = ctx.session_id,
      bounds = { 0.2, 0.25, 0.6, 0.5 }, -- x, y, width, height: fractions of the window
      focus = true,
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        label = "new task",
        options = {
          cwd = HOME .. "/src",
          command = {
            "claude", "--name", "new-task",
            "--append-system-prompt-file", HOME .. "/.config/rex/new-task.md",
            "--allowedTools=" .. CLOSE_SELF,
          },
        },
      },
    }
  end,
}
