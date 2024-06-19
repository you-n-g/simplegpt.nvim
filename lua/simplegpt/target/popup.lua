local M = {
  init = false, -- if it is initialized
  last_pop = nil,
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

function M.update_last_pop(pop)
  if M.last_pop ~= nil then
    -- M.last_pop:unmount()
  end
  M.last_pop = pop
end

function M.build_q_handler(context)
  return function (question)
    local pp = M.Popup(context)
    M.update_last_pop(pp)
    -- set the filetype of pp  to mark down to enable highlight
    pp:build()
    -- TODO: copy code with regex
    vim.api.nvim_buf_set_option(pp.answer_popup.bufnr, 'filetype', 'markdown')
    pp:call(question)
  end
end


function M.resume_popup()
  -- TODO: this is not a elegant way to resume the last popup; research more on popup's hide and show feature(maybe from ChatGPT.nvim).
  -- I just want to hide it. Instead of creating a new one.
  if M.last_pop ~= nil then
    M.last_pop.answer_popup:mount()
    vim.api.nvim_buf_set_lines(M.last_pop.answer_popup.bufnr, 0, -1, false, M.last_pop.full_answer)
    vim.api.nvim_buf_set_option(M.last_pop.answer_popup.bufnr, 'filetype', 'markdown')
    -- M.last_pop.answer_popup:show()  -- TODO: can't resume
    M.last_pop:register_keys()
  end
end

return M
