return {
  -- lua/processfiles/init.lua
  'mfussenegger/nvim-dap-python',
  config = function()
    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
    local dap_python_path
    if vim.loop.os_uname().sysname == "Windows_NT" then
      dap_python_path = home .. '\\AppData\\Local\\nvim-data\\mason\\packages\\debugpy\\venv\\Scripts\\python.exe'
    else
      dap_python_path = home .. '/.local/share/nvim/mason/packages/debugpy/venv/bin/python'
    end
    require('dap-python').setup(dap_python_path)
  end,
}
