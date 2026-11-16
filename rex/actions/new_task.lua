-- New Task…: a floating Claude in ~/src that dispatches whatever you type into
-- worktree sessions (/ticket for a ticket key, /worktree otherwise), then closes
-- itself. Its standing instructions are ../new-task.md.

local HOME = os.getenv("HOME")

rex.action{
  name = "new_task",
  title = "New Task…",
  description = "Describe work in a floating Claude and dispatch it to worktrees.",
  keywords = "worktree dispatch claude ticket",
  run = function(ctx)
    rex.session.new_layer{
      session_id = ctx.session_id,
      bounds = { 0.15, 0.1, 0.7, 0.8 },
      focus = true,
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        label = "new task",
        options = {
          cwd = HOME .. "/src",
          command = {
            "claude", "--name", "new-task",
            "--append-system-prompt-file", HOME .. "/.config/rex/new-task.md",
          },
        },
      },
    }
  end,
}
