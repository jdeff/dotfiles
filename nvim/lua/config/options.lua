local o = vim.opt

-- Display
o.number = true
o.relativenumber = true
o.cursorline = true
o.signcolumn = "yes"        -- avoid layout shift when diagnostics/git signs appear
o.colorcolumn = "80"
o.termguicolors = true
o.scrolloff = 8
o.wrap = false
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Indentation: 2-space soft tabs (Ruby + JS/TS house style; LSP/editorconfig
-- override per project).
o.expandtab = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.smartindent = true
o.autoindent = true

-- Search
o.hlsearch = true
o.incsearch = true
o.ignorecase = true
o.smartcase = true          -- case-sensitive once an uppercase letter is typed
o.gdefault = true           -- :s replaces all matches on a line by default

-- Files / persistence
o.swapfile = false
o.backup = false
o.undofile = true           -- persistent undo across sessions
o.autoread = true

-- Splits
o.splitright = true
o.splitbelow = true

-- Behavior
o.mouse = "a"
o.clipboard = "unnamedplus" -- use the system clipboard
o.timeoutlen = 400
o.updatetime = 250
o.confirm = true            -- prompt instead of failing on unsaved changes

-- Folding via treesitter, all folds open by default
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""
o.foldlevel = 99
o.foldlevelstart = 99
