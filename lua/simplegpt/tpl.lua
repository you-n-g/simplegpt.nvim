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
    -- {{q-}} means register won't be dumped to permanent storage
    -- vim only uses first letter when operating on registers
    ".%-?"
  end
  local reg = "%{%{(" .. key_reg .. ")%}%}"

  -- find all the placeholders
  local keys = {}
  for key in template:gmatch(reg) do
    table.insert(keys, key)
  end
  -- Sort keys lexically
  -- table.sort(keys)
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
  local placeholders = M.get_placeholders()
  self.tpl_pop = Popup({
    enter = #placeholders == 0,
    border = {
      style = "double",
      text = {
        top = "Prompt template:",
        top_align = "center",
      },
    },
    buf_options = {
      filetype = "jinja",
    },
  })

  vim.api.nvim_buf_set_text(self.tpl_pop.bufnr, 0, 0, 0, 0, vim.split(vim.fn.getreg("t"), "\n"))

  -- merge self.pop_dict and pop_dict
  self.all_pops = { self.tpl_pop }

  self.pop_dict = {}
  local reg_cnt = 0
  for _, k in ipairs(placeholders) do
    self.pop_dict[k] = Popup({
      enter = #self.all_pops == #placeholders,  -- Counting a dict is complex, so we use this trick
      border = {
        style = "single",
        text = {
          top = (k:match("^p%-?$") and "Files to be included as context | " or "") .. "register: {{" .. k .. "}}",
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

  -- - save the registers: This applies to only the register template
  -- TODO: auto update register
  for _, pop in ipairs(self.all_pops) do
    pop:map("n", { "<c-s>" }, function()
      self:update_reg()
    end, { noremap = true })
  end

  -- Define custom highlight for special placeholders if not already defined
  local hl_group = "SimpleGPTPlaceholder"
  if vim.fn.hlID(hl_group) == 0 then
    vim.api.nvim_set_hl(0, hl_group, { fg = "#e4c95f", bold = true })
  end

  -- list of special/important keywords to highlight (only those mentioned/used in this file)
  local special_words = {
    "md_context",
    "all_buf",
    "q",
    "content",
    "full_content",
    "i",
    "visual",
    "filetype",
    "context",
    "lsp_diag",
    "terminal",
    "full_terminal",
    "p",
    "filename"
  }

  -- function to highlight placeholders in the buffer
  local function highlight_placeholders(bufnr)
    vim.api.nvim_buf_clear_namespace(bufnr, 0, 0, -1)
    local curr_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for lnum, line in ipairs(curr_lines) do
      for _, word in ipairs(special_words) do
        -- Match {{   word    }} (any amount of spaces between)
        local pattern = "{{%s*" .. word .. "%s*}}"
        local s = 1
        while true do
          local from_col, to_col = line:find(pattern, s)
          if not from_col then break end
          vim.api.nvim_buf_add_highlight(
            bufnr,
            0,
            hl_group,
            lnum - 1,
            from_col - 1,
            to_col
          )
          s = to_col + 1
        end
      end
    end
  end

  -- initial highlight
  highlight_placeholders(self.tpl_pop.bufnr)

  -- automatically re-highlight on buffer/text change
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufEnter", "InsertLeave" }, {
    buffer = self.tpl_pop.bufnr,
    callback = function()
      highlight_placeholders(self.tpl_pop.bufnr)
    end,
    desc = "SimpleGPT: highlight placeholders in template popup",
  })
end


function M.RegQAUI:get_special()
  self:update_reg()

  local res = {}

  -- shared variables
  local cursor_pos = self.context.cursor_pos

  -- 1) all file content
  -- Get the current buffer
  local buf = self.context.from_bufnr
  -- Get the number of lines in the buffer
  local line_count = vim.api.nvim_buf_line_count(buf)
  local content_max_len = require "simplegpt.conf".options.tpl_conf.content_max_len
  -- Get all lines
  local lines = vim.api.nvim_buf_get_lines(buf, math.max(cursor_pos[1] - content_max_len - 1, 0),
    math.min(cursor_pos[1] + content_max_len, line_count), false)
  res["content"] = table.concat(lines, "\n")
  res["full_content"] = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")

  -- 2) get the visual content
  local select_pos = self.context.visual_selection

  if select_pos then
    local start_line = select_pos.start.row - 1 -- Lua indexing is 0-based
    local end_line = select_pos["end"].row
    -- Get the selected lines
    local selected_lines = vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)
    -- Adjust the first and last line based on column selection
    if select_pos.mode == "v" then
      if #selected_lines > 0 then
        -- truncating last line must come first
        selected_lines[#selected_lines] = selected_lines[#selected_lines]:sub(1, select_pos["end"].col)
        selected_lines[1] = selected_lines[1]:sub(select_pos.start.col)
      end
    end
    -- Now 'selected_lines' is a table containing all selected lines
    res.visual = table.concat(selected_lines, "\n")
  end

  -- 3) Get the filetype of the current buffer
  res["filetype"] = self.context.filetype

  -- 4) Get the context of current line (the line under the cursor). Including 10 lines before and 10 lines after
  local context_len = require "simplegpt.conf".options.tpl_conf.context_len
  local start_line = math.max(cursor_pos[1] - context_len - 1, 0) -- Lua indexing is 0-based
  local end_line = math.min(cursor_pos[1] + context_len, line_count)
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

  -- 6) Get LSP diagnostics info
  if select_pos then
    start_line = select_pos.start.row - 1 -- Lua indexing is 0-based
    end_line = select_pos["end"].row
    -- Retrieve diagnostics for the current buffer
    local lsp_info = {}
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, start_line, end_line, false)) do
      table.insert(lsp_info, string.format("Line %02d:%s", start_line + i, line))
    end
    -- Iterate over diagnostics and print them
    local diagnostics = vim.diagnostic.get(buf)
    for _, diagnostic in ipairs(diagnostics) do
      -- vim diagnostics is also 0 based
      if diagnostic.lnum >= start_line and diagnostic.lnum <= end_line then
        table.insert(lsp_info, string.format("LSP diagnostics for line %d: %s", diagnostic.lnum + 1, diagnostic.message))
      end
    end
    res["lsp_diag"] = table.concat(lsp_info, "\n")
  end

  -- 7) Get the content in `.sgpt.md` and render it as {{md_context}}
  local md_file_path = ".sgpt.md"
  if vim.loop.fs_stat(md_file_path) then
    local md_content = {}
    for line in io.lines(md_file_path) do
      table.insert(md_content, line)
    end
    res["md_context"] = table.concat(md_content, "\n")
  end

  -- 8) Get the relative path of the current buffer
  local file_path = vim.api.nvim_buf_get_name(buf)
  res["filename"] = vim.fn.fnamemodify(file_path, ":.") -- Extract the relative path from the full path

  -- 9) Get the terminal buffer content from the first visible terminal buffer, use content_max_len to control the number of lines
  res["terminal"] = nil
  res["full_terminal"] = nil
  for _, _buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[_buf].buftype == 'terminal' and vim.api.nvim_win_is_valid(vim.fn.bufwinid(_buf)) then
      local term_lines = vim.api.nvim_buf_line_count(_buf)
      res["full_terminal"] = vim.api.nvim_buf_get_lines(_buf, 0, -1, false)
      start_line = math.max(term_lines - content_max_len, 0)
      lines = vim.api.nvim_buf_get_lines(_buf, start_line, term_lines, false)
      res["terminal"] = table.concat(lines, "\n")
      break -- Use the first encountered visible terminal buffer
    end
  end

  -- Expanding --
  -- a) Get the content of files listed in {{p}} and render it as a list of file content
  local p_files = vim.fn.getreg("p") -- Assuming the list of file paths is stored in register 'p'
  local file_contents = {}

  for _file_path in p_files:gmatch("[^\r\n]+") do
    -- Trim whitespace from the beginning and end of the file path
    _file_path = vim.trim(_file_path)
    if vim.loop.fs_stat(_file_path) then
      local file_buf = vim.fn.bufnr(_file_path, true) -- Get or create buffer for the file
      if file_buf ~= -1 then
        table.insert(file_contents, M.get_buf_cont(file_buf))
      end
    end
  end
  res["p"] = table.concat(file_contents, "\n")

  return res
end


function M.RegQAUI:get_tpl_values()
  local tpl_values = {}
  for _, k in ipairs(M.get_placeholders()) do
    k = k:gsub("-", "") -- when rendering the template, we should remove the "-" in the placeholder
    tpl_values[k] = vim.fn.getreg(k)
  end
  return vim.tbl_extend("force", tpl_values, self:get_special())
end

function M.RegQAUI:get_q()
  self:update_reg() -- make sure the register is updated.
  local function interp(s, tab)
    -- return (s:gsub("({{.-}})", function(w)
    --   return tab[w:sub(3, -3)] or w
    -- end))
    -- replace {{%l-}} with {{%l}} to make suitable for jinja template
    -- e.g. '{{q-}}' -> '{{q}}'
    s = s:gsub("({{%l-}})", function(w)
      return w:gsub("-", "")
    end)
    -- NOTE: for testing render
    -- local t = {}
    -- for k, v in pairs(tab) do
    --   t[k] = "<placeholder>"
    -- end
    -- return require('jinja').lupa.expand(s, t)
    return require('jinja').lupa.expand(s, tab)
  end
  return interp(M.get_tpl(), self:get_tpl_values())
end

--- register common keys for dialogs
---@param exit_callback
function M.RegQAUI:register_keys(exit_callback)
  M.RegQAUI.super.register_keys(self, exit_callback)
  -- Register TPL_DIALOG_KEYMAPS via add_winbar
  local keymaps = require("simplegpt.conf").get_tpl_dialog_keymaps()
  dialog.add_winbar(self.all_pops[1].winid, keymaps)

  -- Special key bindings for current level of class
  -- 1) Move show value functionality here
  local show_special_key = require("simplegpt.conf").options.dialog.keymaps.show_value
  self.all_pops[1]:map("n", show_special_key, function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local col = cursor_pos[2] + 1 -- Lua uses 1-based indexing

    -- Pattern to match placeholders like {{...}}, supporting names with underscores and numbers
    local pattern = "{{%s*([%w_%d]+)%-?%s*}}"
    local start_pos, end_pos, match = line:find(pattern)

    -- Check if the cursor is within the bounds of a match
    local tpl_values = self:get_tpl_values()
    -- Merge special values into tpl_values
    tpl_values = vim.tbl_extend("force", tpl_values, self:get_special())
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
            zindex = 60,
            border = "none",
            size = {
              width = "30%",
              height = "30%",
            },
            position = {
              row = 0,
              col = end_pos - col,
            },
            relative = "cursor",
            buf_options = {
              modifiable = false,
              readonly = true,
            },
            win_options = {
              winhighlight = "Normal:DarkPopup,FloatBorder:DarkPopupBorder",
            },
          })
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

  -- 2) Register 'Q' to exit the NUI and create a buffer chat with the query
  local buffer_chat_key = require("simplegpt.conf").options.dialog.keymaps.buffer_chat_keys
  for _, pop in ipairs(self.all_pops) do
      pop:map("n", buffer_chat_key, function()
      -- Exit the current NUI
      self:quit()  -- this will switch back to the orginal buffer

      -- Create a buffer chat with self:get_q() as user message
      local buf_chat = require("simplegpt.buf_chat")
      local messages = {
        { role = "user", content = self:get_q() }
      }
      buf_chat.create_chat_buffer(messages)
      
      -- Notify the user
      vim.notify("Created buffer chat with template query", vim.log.levels.INFO)
    end, { noremap = true, desc = "Exit template and create a buffer chat with the query" })
  end
end

function M.get_buf_cont(buf)
  if buf == nil then
    buf = 0 -- current buffer
  end

  -- Get all lines
  -- Load the buffer if it's not already loaded to get the content
  if not vim.api.nvim_buf_is_loaded(buf) then
    vim.fn.bufload(buf)
  end

  -- Get all lines from the buffer
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  -- Get the current file path
  local file_path = vim.api.nvim_buf_get_name(buf)

  local file_type = vim.api.nvim_buf_get_option(buf, "filetype")

  -- Prepare the content to be set into the register
  local content = "- " .. file_path .. ":\n" .. "````" .. file_type .. "\n" .. table.concat(lines, "\n") .. "\n````"
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
