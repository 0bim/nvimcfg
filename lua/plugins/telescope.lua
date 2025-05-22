return {
  -- lua/processfiles/init.lua
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzy-native.nvim",
    'nvim-telescope/telescope-dap.nvim',
  },
  config = function()
    local telescope = require("telescope")

    telescope.setup({
      defaults = {
        -- Default configuration for telescope goes here
        -- You can modify various options such as layout and sorting
        file_ignore_patterns = { "node_modules" },
        -- make telescope start from first file and go down
        sorting_strategy = "ascending",

        -- put search bar at the top
        layout_config = {
          prompt_position = "top",
        },
      },
      extensions = {
        -- Extensions configuration goes here
        "file_browser",
        -- add fuzzy finder
        "fzy_native",

        "dap",
      },
    })

    -- Key mappings
    local map = vim.api.nvim_set_keymap
    local options = { noremap = true, silent = true }

    -- Mapping <leader>f to open find_files
    -- set leader f w to find words
    map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", {})
    map("n", "<leader>b", "<cmd>Telescope buffers<CR>", {})
    map("n", "<leader>h", "<cmd>Telescope help_tags<CR>", {})
    map("n", "<leader>fb", "<cmd>Telescope file_browser<CR>", {})
    map("n", "<leader>fB", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>", {})
    -- make telescope start from first file and go down
    -- load extensions
    telescope.load_extension("fzy_native")
    telescope.load_extension("dap")
    telescope.load_extension("file_browser")


    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values

    local function open_search_menu()
      local opts = {
        prompt_title = "Search Options",
        finder = finders.new_table {
          results = {
            { "Search in current buffer", "current_buffer" },
            { "Search in entire project", "entire_project" }
          },
          entry_maker = function(entry)
            return {
              value = entry[2],
              display = entry[1],
              ordinal = entry[1]
            }
          end
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection.value == "current_buffer" then
              require('telescope.builtin').current_buffer_fuzzy_find()
            elseif selection.value == "entire_project" then
              require('telescope.builtin').live_grep()
            end
          end)
          return true
        end
      }
      pickers.new(opts):find()
    end
    -- map("n", "<leader>fw", "<cmd>Telescope current_buffer_fuzzy_find<CR>", {})

    vim.keymap.set('n', '<leader>fw', function() open_search_menu() end, { noremap = true, silent = true })
  end
}
