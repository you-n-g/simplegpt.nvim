local M = {}
local utils = require("simplegpt.utils")
local dialog = require("simplegpt.dialog")
local Popup = require("nui.popup")
-- local event = require("nui.utils.autocmd").event
local Layout = require("nui.layout")

M.DiffPopup = utils.class("DiffPopup", dialog.ChatDialog)

function M.DiffPopup:ctor(...)
  M.DiffPopup.super.ctor(self, ...)
  self.answer_popup = nil -- the answer content
  self.orig_popup = nil -- the origional content
end

function M.DiffPopup:build()
  -- answer prompt
  local answer_popup = Popup({
    -- relative = "editor",
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = { top = "Response" },
    },
    -- size = "48%",
  })
  self.answer_popup = answer_popup

  -- question prompt
  local orig_popup = Popup({
    -- relative = "editor",
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = { top = "Origin" },
    },
    -- size = "48%",
  })
  self.orig_popup = orig_popup
  local boxes = {}
  for _, p in ipairs({ orig_popup, answer_popup }) do
    table.insert(boxes, Layout.Box(p, { ["size"] = "50%" }))
    table.insert(self.all_pops, p)
  end

  local conf_size = require"simplegpt.conf".options.ui.layout.size
  local layout = Layout({
    relative = "editor",
    position = "50%",
    size = {
      width = conf_size.width,
      height = conf_size.height
    },
  }, Layout.Box(boxes, { dir = "row" }))
  -- mount/open the component
  layout:mount()

  -- unmount component when cursor leaves buffer
  -- TODO: I just want to hide the layout for future resuming
  -- vim.tbl_extend("force", self.all_pops)
  self:register_keys()
end

function M.build_q_handler(context)
  return function(question)
    local dp = M.DiffPopup(context)
    -- M.update_last_pop(dp)
    -- set the filetype of pp  to mark down to enable highlight
    dp:build()
    -- TODO: copy code with regex
    for _, p in ipairs(dp.all_pops) do
      vim.api.nvim_buf_set_option(p.bufnr, "filetype", context["filetype"]) -- todo set to current filetype
    end
    local key_map = {visual="visual", file="full_content"}
    vim.api.nvim_buf_set_lines(dp.orig_popup.bufnr, 0, -1, false, vim.split(context.rqa.special_dict[key_map[context.replace_target]], "\n"))  -- set conttn
    -- -- TODO: put dp.orig_popup.bufnr and dp.answer_popup.bufnr into diff mode

    for _, pop in ipairs(dp.all_pops) do
      vim.api.nvim_set_current_win(pop.winid)
      vim.api.nvim_command("diffthis")
      vim.o.wrap = true  -- make diff more friedly
    end
    vim.api.nvim_set_current_win(dp.answer_popup.winid)
    dp:call(question)
  end
end

return M
