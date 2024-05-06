return {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzy-native.nvim"
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
            },
        })

        -- Key mappings
        local map = vim.api.nvim_set_keymap
        local options = { noremap = true, silent = true }

        -- Mapping <leader>f to open find_files
        -- set leader f w to find words
        map("n", "<leader>fw", "<cmd>Telescope current_buffer_fuzzy_find<CR>", {})
        map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", {})
        map("n", "<leader>g", "<cmd>Telescope live_grep<CR>", {})
        map("n", "<leader>b", "<cmd>Telescope buffers<CR>", {})
        map("n", "<leader>h", "<cmd>Telescope help_tags<CR>", {})
        map("n", "<leader>fb", "<cmd>Telescope file_browser<CR>", {})
        -- make telescope start from first file and go down
    end
}
