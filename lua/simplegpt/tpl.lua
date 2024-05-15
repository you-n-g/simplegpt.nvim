-- This module provides features to presenting the templates, placeholders.
local Popup = require("nui.popup")
local Layout = require("nui.layout")
local dialog = require("simplegpt.dialog")
local utils = require("simplegpt.utils")
local conf = require("simplegpt.conf")
-- TODO:
local M = {}
M.RegQAUI = utils.class("RegQAUI", dialog.BaseDialog) -- register-based QA UI

function M.RegQAUI:ctor(...)
  M.RegQAUI.super.ctor(self, ...)
  self.pop_dict = {} -- a dict of register to popup
  self.tpl_pop = nil -- the popup of template
  self.special_dict = self:get_special() -- we have to get special dict before editing the quesiton.. Ohterwise we'll lose the file and visual selection
  if "" == vim.fn.getreg("t") then
    vim.fn.setreg("t", [[Context:```{{c}}```, {{q}}, {{i}}, Please input your answer:```]])
  end
end

function M.get_tpl()
  return vim.fn.getreg("t")
end

--- This function retrieves all placeholders from a template stored in a vim register "t".
--- Placeholders are defined as any text enclosed in double curly braces, e.g., "{{placeholder}}".
--- For example, if the template is "Hello, {{name}}!", the function will return a table containing "name".
---@param key_reg : for matching the placeholder name (e.g. ".-", ".", "%l")
---@return table : A table containing all placeholders found in the template.
function M.get_placeholders(key_reg)
  local template = M.get_tpl()

  if key_reg == nil then
    key_reg = ".%-?" -- {{q-}} means that the q register will not be dumped into the permanent storage; vim will only use the first letter when operating on registers.
  end
  local reg = "%{%{(" .. key_reg .. ")%}%}"

  -- find all the placeholders
  local keys = {}
  for key in template:gmatch(reg) do
    table.insert(keys, key)
  end
  return keys
end

--- keys = key_sort(tpl_json)
-- Example:
-- -- Now iterate over the sorted keys
-- for _, k in ipairs(keys) do
--   local v = tpl_json[k]
--   -- Rest of your code
-- end
---@param tpl_json
---@return table
function M.key_sort(tpl_json)
  -- Create a table to store the keys
  local keys = {}
  for k in pairs(tpl_json) do
    table.insert(keys, k)
  end

  -- Sort the keys
  table.sort(keys)

  -- If 't' is in the keys, move it to the first
  for i, key in ipairs(keys) do
    if key == "t" then
      table.remove(keys, i)
      table.insert(keys, 1, "t")
      break
    end
  end

  return keys
end

function M.RegQAUI:update_reg()
  vim.fn.setreg("t", table.concat(vim.api.nvim_buf_get_lines(self.tpl_pop.bufnr, 0, -1, true), "\n"))
  for k, p in pairs(self.pop_dict) do
    vim.fn.setreg(k, table.concat(vim.api.nvim_buf_get_lines(p.bufnr, 0, -1, true), "\n"))
  end
  print("Register updated.")
end

function M.RegQAUI:build(callback)
  self.pop_dict = {}
  local reg_cnt = 0
  for _, k in ipairs(M.get_placeholders()) do
    self.pop_dict[k] = Popup({
      border = {
        style = "single",
        text = {
          top = "register: {{" .. k .. "}}",
          top_align = "center",
        },
      },
    })
    reg_cnt = reg_cnt + 1
    vim.api.nvim_buf_set_text(self.pop_dict[k].bufnr, 0, 0, 0, 0, vim.split(vim.fn.getreg(k), "\n"))
  end

  local size = math.floor(100 / (reg_cnt + 1))

  self.tpl_pop = Popup({
    enter = true,
    border = {
      style = "double",
      text = {
        top = "Prompt template:",
        top_align = "center",
      },
    },
  })

  vim.api.nvim_buf_set_text(self.tpl_pop.bufnr, 0, 0, 0, 0, vim.split(vim.fn.getreg("t"), "\n"))

  -- merge self.pop_dict and pop_dict
  self.all_pops = { self.tpl_pop }
  for _, v in pairs(self.pop_dict) do
    table.insert(self.all_pops, v)
  end

  self:register_keys(function()
    -- exit callback
    self:update_reg()
    if callback ~= nil then
      callback(self:get_q())
    end
  end)
  -- - save the registers: This applies to only the register template
  -- TODO: auto update register
  for _, pop in ipairs(self.all_pops) do
    pop:map("n", { "<c-s>" }, function()
      self:update_reg()
    end, { noremap = true })
  end

  -- create boxes and layout
  local boxes = { Layout.Box(self.tpl_pop, { ["size"] = size .. "%" }) }

  for _, v in pairs(self.pop_dict) do
    table.insert(boxes, Layout.Box(v, { ["size"] = size .. "%" }))
  end

  local layout = Layout({
    relative = "editor",
    position = "50%",
    size = {
      width = "90%",
      height = "90%",
    },
  }, Layout.Box(boxes, { dir = "col" }))
  layout:mount()
end

function M.RegQAUI:get_special()
  local res = {}
  --
  -- 1) all file content
  -- Get the current buffer
  local buf = vim.api.nvim_get_current_buf()
  -- Get the number of lines in the buffer
  local line_count = vim.api.nvim_buf_line_count(buf)
  -- Get all lines
  local lines = vim.api.nvim_buf_get_lines(buf, 0, line_count, false)
  res["content"] = table.concat(lines, "\n")

  -- 2) get the visual content
  local select_pos = require("simplegpt.utils").get_visual_selection()
  local start_line = select_pos["start"]["row"] - 1 -- Lua indexing is 0-based
  local end_line = select_pos["end"]["row"]
  -- Get the selected lines
  lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)
  -- Now 'lines' is a table containing all selected lines
  res["visual"] = table.concat(lines, "\n")

  -- 3) Get the filetype of the current buffer
  res["filetype"] = vim.bo.filetype

  -- 4) Get the context of current line (the line under the cursor). Including 10 lines before and 10 lines after
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  start_line = math.max(cursor_pos[1] - 10 - 1, 0) -- Lua indexing is 0-based
  end_line = math.min(cursor_pos[1] + 10, line_count)
  -- Get the context lines
  local context_lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)
  -- Now 'context_lines' is a table containing all context lines
  res["context"] = table.concat(context_lines, "\n")
  return res
end

function M.RegQAUI:get_q()
  local function interp(s, tab)
    return (s:gsub("({{.-}})", function(w)
      return tab[w:sub(3, -3)] or w
    end))
  end
  local ph_keys = {}
  for _, k in ipairs(M.get_placeholders()) do
    ph_keys[k] = vim.fn.getreg(k)
  end
  return interp(M.get_tpl(), vim.tbl_extend("force", ph_keys, self.special_dict))
end

function M.get_current_cont()
  local buf = 0

  -- Get all lines
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  -- Get the current file path
  local file_path = vim.api.nvim_buf_get_name(buf)

  local file_type = vim.api.nvim_buf_get_option(buf, "filetype")

  -- Prepare the content to be set into the register
  local content = "- " .. file_path .. ":\n" .. "```" .. file_type .. "\n" .. table.concat(lines, "\n") .. "\n```"
  return content
end

-- some utils functions
function M.repo_load_file()
  -- Set the content into the register `repo_reg`
  vim.fn.setreg(conf.options.q_build.repo.reg, conf.options.q_build.repo.header .. "\n" .. M.get_current_cont())
  print("Load file content to reg.")
end

function M.repo_append_file()
  local repo_reg = conf.options.q_build.repo.reg
  vim.fn.setreg(repo_reg, vim.fn.getreg(repo_reg) .. M.get_current_cont())
  print("Append file content to reg.")
end

return M
