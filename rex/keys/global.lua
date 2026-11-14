-- Single keys: cmd, alt and function keys.
--
-- Herdr keys that need no line because Rex's default already matches:
--   cmd+t new tab, ctrl+tab / ctrl+shift+tab and shift+cmd+] / [ next/prev tab,
--   cmd+1..9 go to tab, cmd+d / shift+cmd+d split right/down, shift+cmd+enter
--   zoom, alt+cmd+arrows focus pane, cmd+p go to (Herdr's picker), shift+cmd+p
--   palette, cmd+, settings, cmd+= / cmd+- / cmd+0 font size, cmd+f find,
--   alt+left/right, cmd+left/right, cmd+backspace (sent as readline keys).

-- Cmd keys that differ from Rex's defaults.
rex.bind("cmd+w", "client.tab.close")          -- Rex default: close pane, else tab
rex.bind("shift+cmd+w", "pane.close")          -- Rex default: close window
rex.bind("cmd+n", "session.new")               -- Rex default: new window (Herdr: new space)
rex.bind("alt+cmd+]", "session.next")
rex.bind("alt+cmd+[", "session.previous")
rex.bind("cmd+b", "client.sidebar.toggle")
rex.bind("f2", "client.tab.rename")
rex.bind("shift+f2", "session.rename")

-- Herdr's alt+j / alt+k cycle spaces (Rex sessions).
rex.bind("alt+j", "session.next")
rex.bind("alt+k", "session.previous")

-- Readline delete-word, which Rex doesn't send by default.
rex.bind("alt+backspace", "pane.send_key", { key = "ctrl+w" })
