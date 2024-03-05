local M = {}

function M.setup(options)
  require"simplegpt.conf".setup(options)
  require"simplegpt.mappings".setup()
end

return M
