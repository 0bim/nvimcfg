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
        "hrsh7th/cmp-nvim-lua",
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
        { "lukas-reineke/lsp-format.nvim", config = true },
    },
    config = function()
        local lsp = require("lsp-zero")
        lsp.preset("recommended")
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
                "typst_lsp",
            },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({})
                end
            }
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client.server_capabilities.inlayHintProvider then
                    vim.lsp.inlay_hint.enable(true, nil)
                end
                -- whatever other lsp config you want
            end
        })
    end
}
