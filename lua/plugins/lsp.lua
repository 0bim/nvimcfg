return {
    "VonHeikemen/lsp-zero.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "kevinhwang91/nvim-ufo",
        "rafamadriz/friendly-snippets",
        { "lukas-reineke/lsp-format.nvim", config = true },
    },
    config = function()
        require("java").setup()

        local lsp = require("lsp-zero")
        lsp.on_attach(function(client, bufnr)
            require("lsp-format").on_attach(client, bufnr)
        end)
        lsp.setup()
        vim.diagnostic.config { virtual_text = true }

        local mason = require("mason")
        mason.setup({})

        local mason_lspconfig = require("mason-lspconfig")
        mason_lspconfig.setup({
            ensure_installed = {
                "rust_analyzer",
                "pyright",
                "clangd",
                "jdtls",
                "jsonls",
            },
            handlers = {
                function(server_name)
                    if server_name ~= "rust_analyzer" then
                        require("lspconfig")[server_name].setup({})
                    end
                end
            }
        })

        local opts = { noremap = true, silent = true }
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client.server_capabilities.inlayHintProvider then
                    vim.lsp.inlay_hint.enable(true, nil)
                end

                -- mappings
                vim.api.nvim_buf_set_keymap(0, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
                vim.api.nvim_buf_set_keymap(0, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                -- get filetype
                local filetype = vim.api.nvim_buf_get_option(0, "filetype")
                if filetype ~= "rust" then
                    vim.api.nvim_buf_set_keymap(0, "n", "ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
                end
            end
        })
    end
}
