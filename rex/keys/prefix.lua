-- tmux-style prefix sequences: ctrl+b, then a key.

local P = "ctrl+b>"

-- Press ctrl+b twice to send one ctrl+b to the terminal.
rex.bind(P .. "ctrl+b", "pane.send_key", { key = "ctrl+b" })

-- Panes
rex.bind(P .. "shift+\\", "pane.split", { direction = "right" })   -- |
rex.bind(P .. "-", "pane.split", { direction = "down" })
rex.bind(P .. "h", "pane.focus", { direction = "left" })
rex.bind(P .. "j", "pane.focus", { direction = "down" })
rex.bind(P .. "k", "pane.focus", { direction = "up" })
rex.bind(P .. "l", "pane.focus", { direction = "right" })
rex.bind(P .. "x", "pane.close")
rex.bind(P .. "z", "pane.zoom")

-- Tabs
rex.bind(P .. "c", "client.tab.new")
rex.bind(P .. "n", "client.tab.next")
rex.bind(P .. "p", "client.tab.previous")
rex.bind(P .. "shift+t", "client.tab.rename")
rex.bind(P .. "shift+x", "client.tab.close")
for i = 1, 9 do
  rex.bind(P .. i, "client.tab.goto", { index = i })
end

-- Sessions (Herdr spaces)
rex.bind(P .. "shift+n", "session.new")
rex.bind(P .. "shift+w", "session.rename")
rex.bind(P .. "shift+d", "session.close")

-- New Task…: floating Claude that dispatches work to worktrees (actions/new_task.lua)
rex.bind(P .. "t", "new_task")

-- Picker and sidebar
rex.bind(P .. "w", "pane.go_to")
rex.bind(P .. "g", "pane.go_to")
rex.bind(P .. "b", "client.sidebar.toggle")
