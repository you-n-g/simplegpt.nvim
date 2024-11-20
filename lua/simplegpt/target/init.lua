local M = {
  last_dialog = nil,
}

local modules = { "chat", "popup", "diff" }

for _, module in pairs(modules) do
  M = vim.tbl_extend("keep", M, require("simplegpt.target." .. module))
end

function M.set_last_dialog(dialog)
  if require("simplegpt.utils").isinstance(dialog, require("simplegpt.dialog").ChatDialog) then
    -- filter and only record chatdialog
    M.last_dialog = dialog
  end
end

function M.resume_last_dialog()
  if M.last_dialog ~= nil then
    M.last_dialog:show()
  end
end

return M
