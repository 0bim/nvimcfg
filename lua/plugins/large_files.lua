return {
  -- lua/processfiles/init.lua
  "mireq/large_file",
  config = function()
    require("large_file").setup()
  end
}
