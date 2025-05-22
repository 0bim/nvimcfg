return {
  -- lua/processfiles/init.lua
  {
    {
      dir = vim.fn.stdpath("config") .. "/lua/local_plugins/indents",
      lazy = false,
      config = function()
        require("local_plugins.indents").setup()
      end,
    },
    {
      dir = vim.fn.stdpath("config") .. "/lua/local_plugins/processfiles",
      lazy = false,
      config = function()
        require("local_plugins.processfiles").setup()
      end,
    }
  }
}
