return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
        "nvim-neotest/nvim-nio",
        "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
        local mason_nvim_dap = require("mason-nvim-dap")
        mason_nvim_dap.setup({
            ensure_installed = {
                "python",
                "codelldb",
            },
            handlers = {
                function(config)
                    mason_nvim_dap.default_setup(config)
                end,
            }
        })
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup({
            icons = { expanded = "▾", collapsed = "▸" },
            mappings = {
                open = "o",
                remove = "d",
                edit = "e",
                repl = "r",
                toggle = "t",
            },
            expand_lines = vim.fn.has("nvim-0.7"),
            layouts = {
                {
                    elements = {
                        "scopes",
                    },
                    size = 0.3,
                    position = "right"
                },
                {
                    elements = {
                        "repl",
                        "breakpoints"
                    },
                    size = 0.3,
                    position = "bottom",
                },
            },
            floating = {
                max_height = nil,
                max_width = nil,
                border = "single",
                mappings = {
                    close = { "q", "<Esc>" },
                },
            },
            windows = { indent = 1 },
            render = {
                max_type_length = nil,
            },
        })

        vim.fn.sign_define('DapBreakpoint', { text = '🐞' })

        local opts = { noremap = true, silent = true }

        -- Start debugging session
        vim.keymap.set("n", "<leader>ds", function()
            dap.continue()
            ui.toggle({})
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>=", false, true, true), "n", false) -- Spaces buffers evenly
        end, opts)

        -- Set breakpoints, get variable values, step into/out of functions, etc.
        vim.keymap.set("n", "<leader>dl", require("dap.ui.widgets").hover, opts)
        vim.keymap.set("n", "<leader>dc", dap.continue, opts)
        vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, opts)
        vim.keymap.set("n", "<leader>dn", dap.step_over, opts)
        vim.keymap.set("n", "<leader>di", dap.step_into, opts)
        vim.keymap.set("n", "<leader>do", dap.step_out, opts)
        vim.keymap.set("n", "<leader>dC", function()
            dap.clear_breakpoints()
            require("notify")("Breakpoints cleared", "warn")
        end, opts)

        -- Close debugger and clear breakpoints
        vim.keymap.set("n", "<leader>de", function()
            dap.clear_breakpoints()
            ui.toggle({})
            dap.terminate()
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>=", false, true, true), "n", false)
            require("notify")("Debugger session ended", "warn")
        end, opts)

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end
    end
}
