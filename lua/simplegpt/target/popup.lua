local M = {
}
local utils = require("simplegpt.utils")
local dialog = require("simplegpt.dialog")
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

M.Popup = utils.class("Popup", dialog.ChatDialog)

function M.Popup:ctor(...)
  M.Popup.super.ctor(self, ...)
end

function M.Popup:build()
  local conf_size = require"simplegpt.conf".options.ui.layout.size
  local popup = Popup({
    relative = "editor",
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {top = "Response"},
    },
    position = "50%",
    size = {
      width = conf_size.width,
      height = conf_size.height,
    },
  })
  self.answer_popup = popup

  -- mount/open the component
  popup:mount()
  self.nui_obj = popup

  -- unmount component when cursor leaves buffer
  -- Dont' do this. It will stop the QA if we run it on another tab.
  -- TODO: I just want to hide the popup for future resuming
  -- popup:on(event.BufLeave, function()
  --   popup:unmount()
  --   -- popup:hide()
  -- end)

  -- vim.tbl_extend("force", self.all_pops)
  table.insert(self.all_pops, popup)
  self:register_keys()
end

function M.build_q_handler(context)
  return function (question)
    local pp = M.Popup(context)
    -- set the filetype of pp  to mark down to enable highlight
    pp:build()
    -- TODO: copy code with regex
    vim.api.nvim_buf_set_option(pp.answer_popup.bufnr, 'filetype', 'markdown')
    pp:call(question)
  end
end


return M
