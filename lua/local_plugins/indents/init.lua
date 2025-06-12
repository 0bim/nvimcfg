local M = {}
-- lua/processfiles/init.lua

-- baked-in defaults for all the “major” filetypes
local defaults = {
  -- scripting
  lua        = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  vim        = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },

  -- web / markup
  html       = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  css        = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  javascript = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  typescript = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  json       = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  yaml       = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  markdown   = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },

  -- general-purpose
  python     = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },
  ruby       = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  php        = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = true },

  -- systems languages (real tabs)
  c          = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = false },
  cpp        = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = false },
  java       = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = false },
  go         = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = false },
  rust       = { tabstop = 4, shiftwidth = 4, softtabstop = 4, expandtab = false },

  -- shell, SQL, etc.
  sh         = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
  sql        = { tabstop = 2, shiftwidth = 2, softtabstop = 2, expandtab = true },
}

-- plugin config table (mergeable via setup)
local config = {
  defaults = defaults,
  file     = vim.fn.stdpath("config") .. "/indent.lua",
}

-- in-memory override table
local ft_indent = {}

-- apply indent opts to the current buffer
function M.indent(opts)
  local o       = vim.opt_local
  o.tabstop     = opts.tabstop
  o.shiftwidth  = opts.shiftwidth
  o.softtabstop = opts.softtabstop or opts.shiftwidth
  o.expandtab   = opts.expandtab
end

-- persist the ft_indent table to disk
local function save()
  local f, err = io.open(config.file, "w")
  if not f then
    vim.notify("IndentPlugin: could not open file: " .. err, vim.log.levels.ERROR)
    return
  end
  f:write("return " .. vim.inspect(ft_indent))
  f:close()
end

-- setup entrypoint
function M.setup(user_opts)
  -- merge user overrides (if any)
  config = vim.tbl_deep_extend("force", config, user_opts or {})

  -- load saved overrides if the file exists
  local ok, saved = pcall(dofile, config.file)
  if ok and type(saved) == "table" then
    ft_indent = vim.tbl_deep_extend("force", config.defaults, saved)
  else
    ft_indent = vim.tbl_deep_extend("force", config.defaults, {})
  end

  -- on FileType, apply matching settings
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(ctx)
      local opts = ft_indent[ctx.match]
      if opts then
        M.indent(opts)
      end
    end,
  })

  -- define :SetIndent
  vim.api.nvim_create_user_command("SetIndent", function(cmd)
    local args = vim.split(cmd.args, "%s+")
    local ts   = tonumber(args[1])
    if not ts then
      vim.notify("SetIndent: <tabstop> must be a number", vim.log.levels.ERROR)
      return
    end
    local sw = tonumber(args[2]) or ts
    local st = tonumber(args[3]) or sw
    local et = not vim.tbl_contains({ "noet", "false" }, args[4])
    local ft = vim.bo.filetype

    ft_indent[ft] = { tabstop = ts, shiftwidth = sw, softtabstop = st, expandtab = et }
    save()
    M.indent(ft_indent[ft])
    vim.notify(string.format(
      "IndentPlugin: %s → ts=%d sw=%d st=%d expandtab=%s",
      ft, ts, sw, st, tostring(et)
    ))
  end, {
    nargs = "+",
    desc  = "Set & save indent for this filetype: SetIndent <tabstop> <shiftwidth> [softtabstop] [noet]",
  })
end

return M
