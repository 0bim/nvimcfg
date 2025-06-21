return {
  "mrcjkb/rustaceanvim",
  version = '^4', -- Recommended
  config = function()
    -- Update this path
    local extension_path = vim.env.HOME .. '/.vscode/extensions/vadimcn.vscode-lldb-1.10.0/'
    local codelldb_path = extension_path .. 'adapter/codelldb'
    local liblldb_path = extension_path .. 'lldb/lib/liblldb'
    local this_os = vim.uv.os_uname().sysname;

    -- The path is different on Windows
    if this_os:find "Windows" then
      codelldb_path = extension_path .. "adapter\\codelldb.exe"
      liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
    else
      -- The liblldb extension is .so for Linux and .dylib for MacOS
      liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
    end

    local cfg = require('rustaceanvim.config')

    local opts = { noremap = true, silent = true }
    vim.g.rustaceanvim = {
      server = {
        cmd = function()
          local mason_registry = require("mason-registry")

          if mason_registry.is_installed("rust-analyzer") then
            local pkg = mason_registry.get_package("rust-analyzer")
            local path = pkg:get_install_path() .. "/rust-analyzer"
            if vim.fn.executable(path) == 1 then
              return { path }
            end
          end

          return { "rust-analyzer" }
        end,
        on_attach = function()
          vim.api.nvim_buf_set_keymap(0,
            "n",
            "ga",
            "<cmd>RustLsp codeAction<CR>",
            opts
          )
          -- hover actions keymap
          vim.api.nvim_buf_set_keymap(0,
            "n",
            "<leader>k",
            "<cmd>RustLsp hover actions<CR>",
            opts
          )
        end,
      },
      dap = {
        adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
      },
    }
  end

}
