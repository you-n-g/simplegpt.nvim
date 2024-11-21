local utils = require("simplegpt.utils")
local options = require("simplegpt.conf").options

local M = {
  init = false, -- if it is initialized
}
M.BaseDialog = utils.class("BaseDialog")

-- @param context: The context in which the dialog is being created.
function M.BaseDialog:ctor(context)
  self.context = context
  self.nui_obj = nil  -- subclass should assign this object
  self.all_pops = {}  -- all_popups will be a list table
  -- self.quit_action = "quit"
end

function M.BaseDialog:quit()
  -- Quit the dialog window
  -- vim.cmd("q")
  -- self.nui_obj:unmount() -- you can't use umount here. It will make the buffer disappear
  self.nui_obj:hide()
  require"simplegpt.target".set_last_dialog(self)
end

function M.BaseDialog:show()
  self.nui_obj:show()
  -- resume some special options (I expect nui take care of it)
  M.add_winbar(self.all_pops[1].winid, options.base_dialog.key_table)  -- add winbar to the first popup
end

function M.BaseDialog:hide()
  self.nui_obj:hide()
end

--- Extracts the last code block from a given text.
-- This function was originally located in `lua/chatgpt/flows/chat/base.lua` within the ChatGPT.nvim project,
-- but has been copied and adapted for use within this module.
-- @param text: The input text from which the last code block is to be extracted.
-- @return : Returns the extracted code block. If no code block is found within the text, the function returns nil.
local function extract_code(text, cur_line)

  -- Get every line position of the text.
  local cur_pos = 1
  if cur_line ~= nil then
    local line_pos_l = {1}
    for next_line_pos in text:gmatch("[^\n]*\n()") do
      table.insert(line_pos_l, next_line_pos)
    end
    cur_pos = line_pos_l[cur_line]
  end

  -- Iterate through all code blocks in the message using a regular expression pattern
  local recentCodeBlock
  local distance = math.huge
  local cur_dis
  for start_pos, codeBlock, end_pos in text:gmatch("()(```.-```%s*)()") do
    if start_pos <= cur_pos and cur_pos < end_pos then
      cur_dis = 0  -- cur_pos is in range
    else
      -- (end_pos - 1) to make the right boundary of the code block inclusive
      cur_dis = math.min(math.abs(cur_pos - start_pos), math.abs(cur_pos - (end_pos - 1)))
    end
    if cur_dis < distance then
      distance = cur_dis
      recentCodeBlock = codeBlock
    end
  end
  -- If a code block was found, strip the delimiters and return the code
  if recentCodeBlock then
    local index = string.find(recentCodeBlock, "\n")
    if index ~= nil then
      recentCodeBlock = string.sub(recentCodeBlock, index + 1)
    end
    return recentCodeBlock:gsub("```\n", ""):gsub("```", ""):match("^%s*(.-)%s*$")
  end
  return nil
end


--- register common keys for dialogs
---@param exit_callback
function M.BaseDialog:register_keys(exit_callback)
  local all_pops = self.all_pops

  local key_table = options.base_dialog.key_table

  M.add_winbar(self.all_pops[1].winid, key_table)  -- add winbar to the first popup

  -- set keys to escape for all popups
  -- - Quit
  for _, pop in ipairs(all_pops) do
    pop:map("n", key_table.exit_keys, function()

      self:quit() -- callback may open new windows. So we quit the windows before callback

      if exit_callback ~= nil then
        exit_callback()
      end
    end, { noremap = true })
  end

  -- - cycle windows
  local _closure_func = function(i, sft)
    return function()
      -- P(i, sft, (i - 1 + sft) % #all_pops + 1,  all_pops[0].winid, all_pops[1].winid)
      vim.api.nvim_set_current_win(all_pops[(i - 1 + sft) % #all_pops + 1].winid)
    end
  end
  for i, pop in ipairs(all_pops) do
    pop:map("n", key_table.cycle_next, _closure_func(i, 1), { noremap = true })
    pop:map("n", key_table.cycle_prev, _closure_func(i, -1), { noremap = true })
  end

  -- - yank (c)ode
  for _, pop in ipairs(all_pops) do
    pop:map("n", key_table.yank_code, function()
      local full_cont = table.concat(vim.api.nvim_buf_get_lines(pop.bufnr, 0, -1, false), "\n")
      local code = extract_code(full_cont, vim.api.nvim_win_get_cursor(pop.winid)[1])
      -- TODO: get a summary of the code (e.g. number of lines and characters)
      if code then
        require"simplegpt.utils".set_reg(code)

        -- Get a summary of the code
        local num_lines = #vim.split(code, "\n")
        local num_chars = #code
        print(string.format("Yanked Code Summary: %d lines, %d characters", num_lines, num_chars))
      end
    end, { noremap = true })
  end

  -- Add <C-k> as a shortcut to replace the `pop.bufnr` with the code block that is closest to the cursor
  for _, pop in ipairs(all_pops) do
    pop:map("n", key_table.extract_code, function()
      local full_cont = table.concat(vim.api.nvim_buf_get_lines(pop.bufnr, 0, -1, false), "\n")
      local code = extract_code(full_cont, vim.api.nvim_win_get_cursor(pop.winid)[1])
      if code then
        vim.api.nvim_buf_set_lines(pop.bufnr, 0, -1, false, vim.split(code, "\n"))
        print("Replaced buffer content with the closest code block.")
      else
        print("No code block found near the cursor.")
      end
    end, { noremap = true })
  end
end


-- The dialog that are able to get response to a specific PopUps
M.ChatDialog = utils.class("ChatDialog", M.BaseDialog)

function M.ChatDialog:ctor(...)
  M.ChatDialog.super.ctor(self, ...)
  self.answer_popup = nil  -- the popup to display the answer
  self.full_answer = {}
  self.open_in_new_tab = require"simplegpt.conf".options.new_tab
end

function M.ChatDialog:quit()
  M.ChatDialog.super.quit(self)
  if self.open_in_new_tab then
    vim.api.nvim_command('tabclose')
  end
end

function M.ChatDialog:show()
  M.ChatDialog.super.show(self)
  -- resume some special options (I expect nui take care of it)
  M.add_winbar(self.all_pops[#(self.all_pops)].winid, options.dialog.key_table)  -- add winbar to the last pop
end


function M.ChatDialog:call(question)

  -- NOTE: we have to initial ChatGPT.nvim at least once to make the settings effective
  -- FIXME: But if we put it in target/init.lua, it will not work in packer.
  local Settings = require("chatgpt.settings")
  if not M.init then
    Settings.get_settings_panel("chat_completions", require("chatgpt.config").options.openai_params) -- call to make  Settings.params exists
    M.init = true
  end

  local messages = {
    { content = question, role = "user" },
  }

  local params = vim.tbl_extend("keep", { stream = true, messages = messages }, require("chatgpt.settings").params)
  local popup = self.answer_popup -- add it to namespace to support should_stop & cb

  local function should_stop()
    if popup.bufnr == nil then
      -- if the window disappeared, then return False
      return true
    end
    return false
  end

  local function cb(answer, state)
    -- TODO: add processing to title
    -- if state is START or CONTINUE, append answer to popup.bufnr.
    -- Please note that a single line may come via multiple times

    -- set self.popup's title to "state"
    -- self.popup.border.text = {top = state}

    if popup.border.winid ~= nil then
      popup.border:set_text("top", "State: " .. state, "center")
      popup:update_layout()
    end

    if state == "START" or state == "CONTINUE" then
      local line_count = vim.api.nvim_buf_line_count(popup.bufnr)
      local last_line = vim.api.nvim_buf_get_lines(popup.bufnr, line_count - 1, line_count, false)[1]
      -- TODO: if answer contains "\n" or "\r", break it and creat multipe
      local lines = vim.split(answer, "\n")
      for i, line in ipairs(lines) do
        if i == 1 then
          -- append the first line of the answer to the last line in the buffer
          local new_line = last_line .. line
          vim.api.nvim_buf_set_lines(popup.bufnr, line_count - 1, line_count, false, { new_line })
        else
          -- append the remaining lines of the answer as new lines in the buffer
          vim.api.nvim_buf_set_lines(popup.bufnr, -1, -1, false, { line })
        end
      end

      self:update_full_answer()
    end
  end

  require("chatgpt.api").chat_completions(params, cb, should_stop)
end

function M.ChatDialog:update_full_answer()
  self.full_answer = vim.api.nvim_buf_get_lines(self.answer_popup.bufnr, 0, -1, false)
end

function M.add_winbar(winid, key_table)
    -- Add a winbar to the popup window to display additional information
    if vim.fn.has('nvim-0.8') == 1 then  -- Ensure the version supports winbar

      local winbar_content
      local current_winbar = vim.api.nvim_win_get_option(winid, 'winbar')
      if current_winbar and current_winbar ~= "" then
        winbar_content = current_winbar
      else
        winbar_content = "🎹: "
      end
      for k, v in pairs(key_table) do
        winbar_content = winbar_content .. string.format("%s %s|", options.ui_map[k] or k, table.concat(v, ","))
      end
      vim.api.nvim_win_set_option(winid, 'winbar', winbar_content)
    end
end

function M.ChatDialog:register_keys(exit_callback)
  M.ChatDialog.super.register_keys(self, exit_callback)

  M.add_winbar(self.all_pops[#(self.all_pops)].winid, options.dialog.key_table)  -- add winbar to the last pop
  for _, pop in ipairs(self.all_pops) do
    -- Append full answer: append the response to original buffer
    pop:map("n", options.dialog.key_table.append_keys, function()
      self:update_full_answer()  -- Update the full_answer before exit. Please note, it should be called before exit to ensure the buffer exists.

      self:quit()  -- callback may open new windows. So we quit the windows before callback
      if exit_callback ~= nil then
        exit_callback()
      end

      local from_bufnr = self.context["from_bufnr"]
      local last_line = self.context.visual_selection_or_cur_line_or_cur_line["end"].row
      -- Insert `self.full_answer` into from_bufnr after the last line
      vim.api.nvim_buf_set_lines(from_bufnr, last_line, last_line, false, self.full_answer)

    end, { noremap = true })

    -- replace the selected buffer (or current line) with the response
    pop:map("n", options.dialog.key_table.replace_keys, function()
      self:update_full_answer()  -- Update the full_answer before exit. Please note, it should be called before exit to ensure the buffer exists.

      -- TODO: we can support only inserting the code. It may bring more conveniences.

      self:quit()  -- callback may open new windows. So we quit the windows before callback
      if exit_callback ~= nil then
        exit_callback()
      end

      local from_bufnr = self.context["from_bufnr"]

      if self.context.replace_target == "visual" then
        -- Get the range of lines to replace
        local start_line, end_line
        start_line, end_line = self.context.visual_selection_or_cur_line_or_cur_line.start.row, self.context.visual_selection_or_cur_line_or_cur_line["end"].row
        -- Replace the lines in from_bufnr with `self.full_answer`
        vim.api.nvim_buf_set_lines(from_bufnr, start_line - 1, end_line, false, self.full_answer)
      elseif self.context.replace_target == "file" then
        vim.api.nvim_buf_set_lines(from_bufnr, 0, -1, false, self.full_answer)
      end
    end, { noremap = true })

    -- Yank keys
    pop:map("n", options.dialog.key_table.yank_keys, function()
      require"simplegpt.utils".set_reg(table.concat(self.full_answer, "\n"))
      print("answer Yanked")
    end, { noremap = true })
  end
end

return M
