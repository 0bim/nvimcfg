return {
  -- lua/processfiles/init.lua
  dependencies = {
    {
      "kaarmu/typst.vim",
      ft = "typst",
      lazy = false,
    }
  },
  "chomosuke/typst-preview.nvim",
  lazy = false, -- or ft = 'typst'
  version = "0.3.*",
  build = function() require "typst-preview".update() end,
}
