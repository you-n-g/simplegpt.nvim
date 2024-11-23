local M = {}

function M.setup(options)
  require"simplegpt.conf".setup(options)
  require"simplegpt.keymaps".setup()
end

return M
