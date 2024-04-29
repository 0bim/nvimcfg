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
            }
        })
    end
}
