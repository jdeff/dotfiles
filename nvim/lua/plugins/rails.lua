return {
  -- Rails navigation + projections: :A (alternate), :Emodel, :Econtroller,
  -- gf into partials/helpers, and ecosystem-aware `gf`.
  {
    "tpope/vim-rails",
    dependencies = { "tpope/vim-projectionist" },
    ft = { "ruby", "eruby", "haml", "slim" },
    cmd = { "Rails", "Emodel", "Econtroller", "Eview", "Eschema", "A", "AV", "AS" },
    keys = {
      { "<leader>ra", "<cmd>A<cr>", desc = "Rails: alternate file (impl/spec)" },
      { "<leader>rr", "<cmd>R<cr>", desc = "Rails: related file" },
    },
  },

  -- Bundler awareness (:Bundle, gf into gems) and rake tasks.
  { "tpope/vim-bundler", ft = { "ruby", "eruby" }, cmd = { "Bundle" } },
  { "tpope/vim-rake", ft = { "ruby" }, cmd = { "Rake" } },
}
