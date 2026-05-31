-- Tim Pope staples. (fugitive, rails, bundler, rake, dadbod, projectionist
-- live in their own topic files; surround/commenting/endwise are covered by
-- modern equivalents.)
return {
  -- Make `.` repeat plugin maps (surround, substitute, unimpaired, …).
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- Auto-detect indent (shiftwidth/expandtab) per file; complements the
  -- 2-space default for repos that differ.
  { "tpope/vim-sleuth", event = { "BufReadPre", "BufNewFile" } },

  -- Bracket mappings: [q ]q (quickfix), [b ]b (buffers), [<Space> ]<Space>
  -- (blank lines), [e ]e (move line), yo<x> (toggle options), …
  { "tpope/vim-unimpaired", event = "VeryLazy" },

  -- Case coercion (crs snake, crc camel, cru upper, …), :Subvert case-aware
  -- search/replace, and smart abbreviations.
  { "tpope/vim-abolish", event = "VeryLazy" },

  -- Unix file commands in the editor: :Rename, :Move, :Delete, :Chmod,
  -- :Mkdir, :SudoWrite.
  { "tpope/vim-eunuch", cmd = { "Rename", "Move", "Delete", "Chmod", "Mkdir", "SudoWrite", "Remove" } },
}
