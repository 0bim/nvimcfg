local function dump(o)
  -- lua/processfiles/init.lua
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end
return {
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
    "jay-babu/mason-nvim-dap.nvim",
    "ldelossa/nvim-dap-projects",
    "axkirillov/easypick.nvim",
  },
  config = function()
    local function pick_process(callback)
      local opts = require('telescope.themes').get_dropdown {}
      local results = {}

      if vim.fn.has('win32') == 1 then
        results = vim.fn.systemlist('tasklist /FO CSV /NH')
      else
        results = vim.fn.systemlist('ps -eo pid,comm')
      end
      require('telescope.pickers').new(opts, {
        prompt_title = 'Select Process',
        finder = require('telescope.finders').new_table {
          results = results,
          entry_maker = function(entry)
            local pid, cmd
            if vim.fn.has('win32') == 1 then
              -- handle CSV correctly
              cmd, pid = entry:match('"(.-)","(.-)",')
            else
              -- skip any non-matching lines (e.g., headers or empty lines)
              cmd, pid = entry:match('^(%d+)%s+(.*)')
            end
            if pid and cmd then
              return {
                value = cmd,
                display = cmd .. ' ' .. pid,
                ordinal = cmd .. ' ' .. pid,
                pid = tonumber(pid)
              }
            end
          end
        },
        sorter = require('telescope.config').values.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
          local actions = require('telescope.actions')
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = require('telescope.actions.state').get_selected_entry()
            vim.notify("selected: " .. dump(selection))
            callback(selection.pid)
          end)
          return true
        end,
      }):find()
    end

    local function pick_executable(callback)
      local function is_executable(file)
        return vim.fn.executable(file) == 1
      end

      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')
      local fb_actions = require('telescope._extensions.file_browser.actions')

      local function update_prompt_title(prompt_bufnr)
        local current_picker = action_state.get_current_picker(prompt_bufnr)
        local finder = current_picker.finder
        local current_path = finder.path or finder.cwd
        current_picker.prompt_border:change_title('Select Executable in ' .. current_path)
      end

      require('telescope').extensions.file_browser.file_browser({
        prompt_title = 'Select Executable',
        cwd = '/',
        hidden = true,             -- Show hidden files
        respect_gitignore = false, -- Ignore gitignore rules
        attach_mappings = function(prompt_bufnr, map)
          map('i', '<CR>', function()
            local selection = action_state.get_selected_entry()

            if selection and is_executable(selection.path) then
              actions.close(prompt_bufnr)
              callback(selection.path)
            elseif selection and selection.path and vim.fn.isdirectory(selection.path) == 1 then
              fb_actions.change_cwd(prompt_bufnr, selection.path)
              update_prompt_title(prompt_bufnr)
            else
              vim.api.nvim_err_writeln('Selected file is not executable!')
            end
          end)

          -- map('i', '<BS>', function()
          --     fb_actions.goto_parent_dir(prompt_bufnr)
          --     update_prompt_title(prompt_bufnr)
          -- end)

          map('i', '<C-p>', function()
            local new_path = vim.fn.input('Enter path: ', '', 'dir')
            if vim.fn.isdirectory(new_path) == 1 then
              fb_actions.change_cwd(prompt_bufnr, new_path)
              update_prompt_title(prompt_bufnr)
            else
              vim.api.nvim_err_writeln('Invalid path!')
            end
          end)

          return true
        end,
      })
    end

    local function get_lldb_path()
      local handle = io.popen('where codelldb.exe')
      local result = handle:read("*a")
      handle:close()
      return result:gsub("%s+", "") -- trim whitespace
    end

    local mason_nvim_dap = require("mason-nvim-dap")
    local dap = require("dap")
    mason_nvim_dap.setup({
      ensure_installed = {
        "debugpy",
        "codelldb"
      },
      automatic_installation = true,
      handlers = {
        function(config)
          mason_nvim_dap.default_setup(config)
        end,
        codelldb = function(config)
          config.configurations = {
            {
              name = "Launch",
              type = "codelldb",
              request = "launch",
              program = function()
                local co = coroutine.running()
                pick_executable(function(file)
                  coroutine.resume(co, file)
                end)
                local selected_file = coroutine.yield()
                -- Ensure the file exists
                if vim.fn.filereadable(selected_file) == 0 then
                  vim.notify("Selected file does not exist: " .. selected_file, vim.log.levels.ERROR)
                  return nil
                end
                return selected_file
              end,
              cwd = "${workspaceFolder}",
              stopOnEntry = false,
              args = {},
              runInTerminal = false,
            },
            {
              name = "Attach",
              type = "codelldb",
              request = "attach",
              pid = function()
                local co = coroutine.running()
                pick_process(function(pid)
                  coroutine.resume(co, pid)
                end)
                local selected_pid = coroutine.yield()
                -- Ensure the pid is valid
                if type(selected_pid) ~= "number" or selected_pid <= 0 then
                  vim.notify("Invalid PID selected: " .. tostring(selected_pid), vim.log.levels.ERROR)
                  return nil
                end
                return selected_pid
              end,
              -- pid = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
            },
          }

          config.adapters = {
            type = 'server',
            port = "${port}",
            executable = {
              command = get_lldb_path(),
              args = { "--port", "${port}" },
              detached = false,
            }
          }

          mason_nvim_dap.default_setup(config)
          dap.configurations.rust = config.configurations;
        end,
      },
    })

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
      {
        {
          elements = {
            -- Elements can be strings or table with id and size keys.
            { id = "scopes", size = 0.25 },
            "breakpoints",
            "stacks",
            "watches",
          },
          size = 40, -- 40 columns
          position = "left",
        },
        {
          elements = {
            "repl",
            "console",
          },
          size = 0.25, -- 25% of total lines
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
      controls = {
        enabled = true,
      }
    })

    vim.fn.sign_define('DapBreakpoint', { text = '🐞' })

    local opts = { noremap = true, silent = true }

    -- Start debugging session
    vim.keymap.set("n", "<leader>ds", function()
      dap.continue()
      ui.toggle({})
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>=", false, true, true), "n", false) -- Spaces buffers evenly
    end, opts)

    vim.fn.sign_define('DapBreakpoint', { text = '', texthl = '', linehl = '', numhl = '' })

    vim.api.nvim_set_keymap('n', '<F5>', ":lua require'dap'.continue()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<F10>', ":lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<F11>', ":lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<F12>', ":lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>db', ":lua require'dap'.toggle_breakpoint()<CR>",
      { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>dB',
      ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
      { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>lp',
      ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
      { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>dr', ":lua require'dap'.repl.open()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>dl', ":lua require'dap'.run_last()<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>dp', ":lua require'telescope'.extensions.dap.commands{}<CR>",
      { noremap = true, silent = true })

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


    require("nvim-dap-projects").search_project_config()
  end
}
