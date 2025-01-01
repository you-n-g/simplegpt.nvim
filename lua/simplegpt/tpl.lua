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
  self.pop_dict = {}                     -- a dict of register to popup
  self.tpl_pop = nil                     -- the popup of template
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
---@return table : A table containing all placeholders found in the template(e.g. "q-", "all_buf").
function M.get_placeholders(key_reg)
  local template = M.get_tpl()

  if key_reg == nil then
    key_reg =
    ".%-?"           -- {{q-}} means that the q register will not be dumped into the permanent storage; vim will only use the first letter when operating on registers.
  end
  local reg = "%{%{(" .. key_reg .. ")%}%}"

  -- find all the placeholders
  local keys = {}
  for key in template:gmatch(reg) do
    table.insert(keys, key)
  end
  -- Sort keys lexically
  table.sort(keys)
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
  vim.api.nvim_buf_set_option(self.tpl_pop.bufnr, "filetype", "jinja")

  -- merge self.pop_dict and pop_dict
  self.all_pops = { self.tpl_pop }

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
    table.insert(self.all_pops, self.pop_dict[k])
  end

  -- create boxes and layout
  local size = math.floor(100 / (#self.all_pops))
  local boxes = { Layout.Box(self.tpl_pop, { ["size"] = size .. "%" }) }

  for _, v in ipairs({unpack(self.all_pops, 2, #self.all_pops)}) do  -- FIXME: it will not work in lua 5.2
    table.insert(boxes, Layout.Box(v, { ["size"] = size .. "%" }))
  end

  local conf_size = require"simplegpt.conf".options.ui.layout.size
  local layout = Layout({
    relative = "editor",
    position = "50%",
    size = {
      width = conf_size.width,
      height = conf_size.height,
    },
  }, Layout.Box(boxes, { dir = "col" }))

  layout:mount()
  self.nui_obj = layout

  -- register keys after mount. Thus we can get the winid to set winbar
  self:register_keys(function()
    -- exit callback
    self:update_reg()
    if callback ~= nil then
      callback(self:get_q())
    end
  end)

  local show_special_key = require("simplegpt.conf").options.dialog.keymaps.show_value
  self.all_pops[1]:map("n", show_special_key, function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local col = cursor_pos[2] + 1 -- Lua uses 1-based indexing

    -- Pattern to match placeholders like {{...}}
    local pattern = "{{%s*(%w+)%-?%s*}}"
    local start_pos, end_pos, match = line:find(pattern)

    -- Check if the cursor is within the bounds of a match
    local tpl_values = self:get_tpl_values()
    while start_pos do
      if col >= start_pos and col <= end_pos then
        if tpl_values[match] then
          vim.cmd([[
            highlight DarkPopup guibg=#1e1e1e guifg=#ffffff
            highlight DarkPopupBorder guibg=#1e1e1e guifg=#ffffff
          ]])
          -- Calculate popup position based on current cursor position
          local popup = Popup({
            enter = false,
            focusable = true,
            zindex = 60, -- This ensures that register popups also have the highest priority
            -- border = {
            --   style = "rounded",
            --   text = {
            --     top = match,
            --     top_align = "center",
            --   },
            -- },
            border = "none",
            size = {
              width = "30%",
              height = "30%",
            },
            -- position = "50%",
            position = {
              row = 0,
              col = end_pos - col,
            },
            relative = "cursor",
            -- size = {
            --   width = 80,
            --   height = "auto",
            -- },
            buf_options = {
              modifiable = false,
              readonly = true,
            },
            win_options = {
              winhighlight = "Normal:DarkPopup,FloatBorder:DarkPopupBorder",
              -- scrollbar = true, -- Enable scrollbar
            },
          })
          -- Set the lines in the buffer
          vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, vim.split(tpl_values[match], "\n"))
          popup:mount()
          local timer = vim.loop.new_timer()
          timer:start(
            3000,
            0,
            vim.schedule_wrap(function()
              if vim.api.nvim_win_is_valid(popup.winid) and vim.api.nvim_get_current_win() ~= popup.winid then
                popup:unmount()
              end
            end)
          )
          vim.api.nvim_create_autocmd("BufLeave", {
            buffer = popup.bufnr,
            callback = function()
              if vim.api.nvim_win_is_valid(popup.winid) then
                popup:unmount()
              end
            end,
          })
        else
          print("No special value for '" .. match .. "' under cursor.")
        end
        return
      end
      start_pos, end_pos, match = line:find(pattern, end_pos + 1)
    end
    print("No placeholder under cursor.")
  end, { noremap = true, desc = "Show Special Value for placeholder under cursor" })
  -- - save the registers: This applies to only the register template
  -- TODO: auto update register
  for _, pop in ipairs(self.all_pops) do
    pop:map("n", { "<c-s>" }, function()
      self:update_reg()
    end, { noremap = true })
  end

end

function M.RegQAUI:get_special()
  local res = {}

  -- shared variables
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- 1) all file content
  -- Get the current buffer
  local buf = vim.api.nvim_get_current_buf()
  -- Get the number of lines in the buffer
  local line_count = vim.api.nvim_buf_line_count(buf)
  local content_max_len = require "simplegpt.conf".options.tpl_conf.content_max_len;
  -- Get all lines
  local lines = vim.api.nvim_buf_get_lines(buf, math.max(cursor_pos[1] - content_max_len - 1, 0),
    math.min(cursor_pos[1] + content_max_len, line_count), false)
  res["content"] = table.concat(lines, "\n")
  res["full_content"] = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")

  -- 2) get the visual content
  local select_pos = require("simplegpt.utils").get_visual_selection(true)

  if select_pos then
    local start_line = select_pos.start.row - 1 -- Lua indexing is 0-based
    local end_line = select_pos["end"].row
    -- Get the selected lines
    local selected_lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)
    -- Adjust the first and last line based on column selection
    if #selected_lines > 0 then
      -- truncating last line must come first
      selected_lines[#selected_lines] = selected_lines[#selected_lines]:sub(1, select_pos["end"].col)
      selected_lines[1] = selected_lines[1]:sub(select_pos.start.col + 1)
    end
    -- Now 'selected_lines' is a table containing all selected lines
    res.visual = table.concat(selected_lines, "\n")
  end

  -- 3) Get the filetype of the current buffer
  res["filetype"] = vim.bo.filetype

  -- 4) Get the context of current line (the line under the cursor). Including 10 lines before and 10 lines after
  local context_len = require "simplegpt.conf".options.tpl_conf.context_len;
  start_line = math.max(cursor_pos[1] - context_len - 1, 0) -- Lua indexing is 0-based
  end_line = math.min(cursor_pos[1] + context_len, line_count)
  -- Get the context lines
  local context_lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)
  -- Now 'context_lines' is a table containing all context lines
  res["context"] = table.concat(context_lines, "\n")

  -- 5) Get content in all buffers that have corresponding files on disk; use get_buf_cont
  local all_buf = {conf.options.q_build.repo.header}
  for _, _buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(_buf) and vim.api.nvim_buf_get_option(_buf, "buflisted") then
      local file_path = vim.api.nvim_buf_get_name(_buf)
      if file_path ~= "" and vim.loop.fs_stat(file_path) then
        table.insert(all_buf, M.get_buf_cont(_buf))
      end
    end
  end
  res["all_buf"] = table.concat(all_buf, "\n")
  return res
end

function M.RegQAUI:get_tpl_values()
  local tpl_values = {}
  for _, k in ipairs(M.get_placeholders()) do
    k = k:gsub("-", "") -- when rendering the template, we should remove the "-" in the placeholder
    tpl_values[k] = vim.fn.getreg(k)
  end
  return vim.tbl_extend("force", tpl_values, self.special_dict)
end
function M.RegQAUI:get_q()
  local function interp(s, tab)
    -- return (s:gsub("({{.-}})", function(w)
    --   return tab[w:sub(3, -3)] or w
    -- end))
    -- replace all {{%l-}} to {{%l}} in s: e.g. '{{q-}}' -> '{{q}}' to make it suitable for standard jinja template engine
    s = s:gsub("({{%l-}})", function(w)
      return w:gsub("-", "")
    end)
    return require('jinja').lupa.expand(s, tab)
  end
  return interp(M.get_tpl(), self:get_tpl_values())
end

function M.get_buf_cont(buf)
  if buf == nil then
    buf = 0 -- current buffer
  end

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
  vim.fn.setreg(conf.options.q_build.repo.reg, conf.options.q_build.repo.header .. "\n" .. M.get_buf_cont())
  print("Load file content to reg.")
end

function M.repo_append_file()
  local repo_reg = conf.options.q_build.repo.reg
  vim.fn.setreg(repo_reg, vim.fn.getreg(repo_reg) .. M.get_buf_cont())
  print("Append file content to reg.")
end

return M
