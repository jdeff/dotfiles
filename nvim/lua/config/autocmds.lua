local augroup = function(name)
  return vim.api.nvim_create_augroup("config_" .. name, { clear = true })
end

-- Briefly highlight yanked text.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Jump to the last edit position when reopening a file.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close throwaway/utility buffers with `q`.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "neotest-output", "neotest-summary" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Treat .arb / .jbuilder etc. and Rails-specific files as ruby where useful.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("ruby_ft"),
  pattern = { "*.rb", "Gemfile", "*.rake", "*.jbuilder", "Brewfile" },
  callback = function(event)
    vim.bo[event.buf].filetype = "ruby"
  end,
})
