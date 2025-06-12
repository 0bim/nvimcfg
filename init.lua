vim.g.mapleader = " "
-- lua/processfiles/init.lua
vim.o.number = true             -- Enable line numbers
vim.o.relativenumber = true     -- Enable relative line numbers
vim.o.tabstop = 4               -- Number of spaces a tab represents
vim.o.shiftwidth = 4            -- Number of spaces for each indentation
vim.o.expandtab = true          -- Convert tabs to spaces
vim.o.smartindent = true        -- Automatically indent new lines
vim.o.wrap = false              -- Disable line wrapping
vim.o.cursorline = true         -- Highlight the current line
vim.o.clipboard = "unnamedplus" -- allow vim to use system clipboard

-- stop deselection after formatting text
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true })
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true })

-- lazy bootstrap
require "lazy-bootstrap"

-- set color schme
vim.cmd("colorscheme dark_flat")

-- make background transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "none" })

-- vim.cmd("filetype plugin indent on")
