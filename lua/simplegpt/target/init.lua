local M = {}

local modules = { "chat", "popup", "diff" }

for _, module in pairs(modules) do
  M = vim.tbl_extend("keep", M, require("simplegpt.target." .. module))
end

return M
