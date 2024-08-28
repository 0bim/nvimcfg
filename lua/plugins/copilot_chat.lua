return {
    "CopilotC-Nvim/CopilotChat.nvim",
    config = function()
        require('CopilotChat').setup({
            prompts = {
                Explain = "Explain how it works.",
                Review = "Review the following code and provide concise suggestions.",
                Tests = "Briefly explain how the selected code works, then generate unit tests.",
                Refactor = "Refactor the code to improve clarity and readability.",
            },
            build = function()
              vim.notify("Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
            end,
            event = "VeryLazy",
        })

        local chat = require('CopilotChat')
        local select = require('CopilotChat.select')
        vim.api.nvim_set_keymap('n', '<leader>ccv', '<cmd>CopilotChatVisual<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>cci', '<cmd>CopilotChatInPlace<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>ccs', '<cmd>CopilotChat<cr>', { noremap = true, silent = true })
        vim.api.nvim_set_keymap('n', '<leader>ccb', '<cmd>CopilotChatBuffer<cr>', { noremap = true, silent = true })

        vim.api.nvim_create_user_command('CopilotChatVisual', function(args)
            chat.ask(args.args, { selection = select.visual })
        end, { nargs = '*', range = true })

        -- Restore CopilotChatInPlace (sort of)
        vim.api.nvim_create_user_command('CopilotChatInPlace', function(args)
            chat.ask(args.args, { selection = select.visual, window = { layout = 'float' } })
        end, { nargs = '*', range = true })

        -- Restore CopilotChatBuffer
        vim.api.nvim_create_user_command('CopilotChatBuffer', function(args)
            chat.ask(args.args, { selection = select.buffer })
        end, { nargs = '*', range = true })

        -- Restore CopilotChatVsplitToggle
        vim.api.nvim_create_user_command('CopilotChatVsplitToggle', chat.toggle, {})
    end,
}
