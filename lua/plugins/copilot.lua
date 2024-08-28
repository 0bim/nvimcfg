return { 
  {
      "zbirenbaum/copilot.lua",
      event = "VimEnter",
      config = function()
          require("copilot").setup({
              suggestion = { enabled = false },
              panel = { enabled = false },
          })
      end
  },
  {
      "zbirenbaum/copilot-cmp",
      config = function ()
        require("copilot_cmp").setup({
            event = { "InsertEnter", "LspAttach" },
            fix_pairs = true,
        })
      end
  },
}
