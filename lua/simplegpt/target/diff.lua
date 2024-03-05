local M = {}
local utils = require("simplegpt.utils")
local dialog = require("simplegpt.dialog")
local Popup = require("nui.popup")
-- local event = require("nui.utils.autocmd").event
local Layout = require("nui.layout")

M.DiffPopup = utils.class("Popup", dialog.ChatDialog)

function M.DiffPopup:ctor(...)
  M.DiffPopup.super.ctor(self, ...)
  self.a_popup = nil -- the answer content
  self.orig_popup = nil -- the origional content
end

function M.DiffPopup:build()
  -- answer prompt
  local a_popup = Popup({
    -- relative = "editor",
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = { top = "Response" },
    },
    -- size = "48%",
  })
  self.a_popup = a_popup
  self.popup = a_popup

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
  for _, p in ipairs({ orig_popup, a_popup }) do
    table.insert(boxes, Layout.Box(p, { ["size"] = "50%" }))
    table.insert(self.all_pops, p)
  end

  local layout = Layout({
    relative = "editor",
    position = "50%",
    size = {
      width = "90%",
      height = "90%",
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
    vim.api.nvim_buf_set_lines(dp.orig_popup.bufnr, 0, -1, false, vim.split(context.rqa.special_dict["visual"], "\n"))  -- set conttn
    -- -- TODO: put dp.orig_popup.bufnr and dp.a_popup.bufnr into diff mode

    for _, pop in ipairs(dp.all_pops) do
      vim.api.nvim_set_current_win(pop.winid)
      vim.api.nvim_command("diffthis")
      vim.o.wrap = true  -- make diff more friedly
    end
    vim.api.nvim_set_current_win(dp.a_popup.winid)
    dp:call(question)
  end
end


return M
