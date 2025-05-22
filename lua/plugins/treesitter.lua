return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "html",
      "javascript",
      "json",
      "lua",
      "python",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "yaml",
      "rust",
      "typst",
      "c",
      "cpp",
      "matlab",
      "prisma",
    },
    highlight = {
      enable = true,
    },
    indent = {
      enable = true,
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end,
}
