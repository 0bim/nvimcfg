-- lua/processfiles/init.lua
local M = {}

-- default filetype → extension map
local default_ext_map = {
  javascript = "js",
  typescript = "ts",
  python = "py",
  lua = "lua",
  ruby = "rb",
  php = "php",
  html = "html",
  css = "css",
  json = "json",
  yaml = "yaml",
  yml = "yml",
  markdown = "md",
  vim = "vim",
  c = "c",
  cpp = "cpp",
  java = "java",
  go = "go",
  rust = "rs",
  sh = "sh",
  sql = "sql",
}

-- plugin config
local config = {
  ext_map = default_ext_map,
}

--- Setup the ProcessFiles command
-- @param user_opts.ext_map  table of filetype→ext to override defaults
function M.setup(user_opts)
  if user_opts and user_opts.ext_map then
    config.ext_map = vim.tbl_deep_extend("force", default_ext_map, user_opts.ext_map)
  end

  vim.api.nvim_create_user_command("ProcessFiles", function(cmd)
    -- 1) decide which filetypes to target
    local fts = (#cmd.fargs > 0) and cmd.fargs or { vim.bo.filetype }

    -- 2) gather all matching files
    local files = {}
    for _, ft in ipairs(fts) do
      local ext = config.ext_map[ft] or ft
      for _, f in ipairs(vim.fn.glob("**/*." .. ext, false, true)) do
        table.insert(files, f)
      end
    end

    if vim.tbl_isempty(files) then
      vim.notify(
        "ProcessFiles: no files found for filetypes: " .. table.concat(fts, ", "),
        vim.log.levels.WARN
      )
      return
    end

    -- 3) load each file into args and write it (always triggers BufWrite autocommands)
    vim.cmd("args " .. table.concat(vim.tbl_map(vim.fn.fnameescape, files), " "))
    vim.cmd("silent argdo write")

    vim.notify(
      ("ProcessFiles: opened & saved %d files for filetypes: %s")
      :format(#files, table.concat(fts, ", ")),
      vim.log.levels.INFO
    )
  end, {
    nargs    = "*",
    complete = "filetype",
    desc     = [[
ProcessFiles [ft1 ft2 …]

Recursively glob **/*.<ext> (ext from filetype map),
:edit each → fire FileType/autocmd → :write to disk (triggering BufWrite hooks,
but without modifying content).
If no filetypes given, defaults to current buffer’s &filetype.
    ]],
  })
end

return M
