local utils = require("simplegpt.utils")
local conf = require("simplegpt.conf")
local search_replace = require("simplegpt.search_replace")
local options = conf.options

--- @class DialogContext
--- @field from_bufnr number         The buffer number where the request originated.
--- @field visual_selection table    Represents either a visual selection: {start, end, mode} positions.
--- @field replace_target string     Specifies what to replace ('visual', 'file', etc.).
--- @field filetype string           The filetype of the originating buffer.
--- @field cursor_pos table          The current cursor position in the form {line, col}.
--- @field rqa RegQAUI             An instance of the RegQAUI class for building questions and answers.
--- @field additional? table         Optional context-specific data needed for dialog operations.

local M = {
  init = false, -- if it is initialized
}
M.BaseDialog = utils.class("BaseDialog")

--- BaseDialog constructor
--- @param context DialogContext A table containing the dialog creation environment.
function M.BaseDialog:ctor(context)
  self.context = context
  self.nui_obj = nil -- subclass should assign this object
  self.all_pops = {} -- all_popups will be a list table
  -- self.quit_action = "quit"

  require("simplegpt.target").set_last_dialog(self)
  self.conversation = {}
end

function M.BaseDialog:build()
  -- Responsibilities of this method:
  -- 1. Construct the dialog interface.
  -- 2. Subclasses must implement this method to define the specific UI components and layout.
  -- 3. Initialize and configure the `nui_obj` and any other necessary elements.
  -- 4. Register keys.
  -- 5. Show the nui.
  error("The build method must be implemented by subclasses")
end

--- Switch back to the window containing the original buffer
function M.BaseDialog:switch_to_original_window()
  if self.context == nil then
    return
  end
  local from_bufnr = self.context.from_bufnr
  if from_bufnr and vim.api.nvim_buf_is_valid(from_bufnr) then
    local winid = vim.fn.bufwinid(from_bufnr)
    if winid ~= -1 then
      vim.api.nvim_set_current_win(winid)
    end
  end
end

function M.BaseDialog:quit()
  -- Quit the dialog window
  self.nui_obj:hide()
  self:switch_to_original_window()
end

function M.BaseDialog:show()
  self.nui_obj:show()
  -- resume some special options (I expect nui take care of it)
  M.add_winbar(self.all_pops[1].winid, conf.get_base_dialog_keymaps()) -- add winbar to the first popup
end

function M.BaseDialog:hide()
  self.nui_obj:hide()
  self:switch_to_original_window()
end

function M.BaseDialog:toggle_window()
  if self.nui_obj._.mounted then
    self:hide()
  else
    self:show()
  end
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
    local line_pos_l = { 1 }
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
      cur_dis = 0 -- cur_pos is in range
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
    local index = string.find(recentCodeBlock, "\n") -- strip the first line
    if index ~= nil then
      recentCodeBlock = string.sub(recentCodeBlock, index + 1)
    end
    return recentCodeBlock
      :gsub("```\n", "")
      :gsub("```", "")
      :match("^(.-)%s*$") -- Keep first indents (don't use "^%s*(.-)%s*$")
  end
  return nil
end

--- register common keys for dialogs
---@param exit_callback
function M.BaseDialog:register_keys(exit_callback)
  local all_pops = self.all_pops

  local keymaps = conf.get_base_dialog_keymaps()

  M.add_winbar(self.all_pops[1].winid, keymaps) -- add winbar to the first popup

  -- - cycle windows
  local _closure_func = function(i, sft)
    return function()
      -- P(i, sft, (i - 1 + sft) % #all_pops + 1,  all_pops[0].winid, all_pops[1].winid)
      vim.api.nvim_set_current_win(all_pops[(i - 1 + sft) % #all_pops + 1].winid)
    end
  end

  -- set keys to escape for all popups
  -- - Quit
  for _, pop in ipairs(all_pops) do
    pop:map("n", keymaps.exit_keys, function()
      self:quit() -- callback may open new windows. So we quit the windows before callback

      if exit_callback ~= nil then
        exit_callback()
      end
    end, { noremap = true })

    pop:map("n", keymaps.cycle_next, _closure_func(i, 1), { noremap = true })
    pop:map("n", keymaps.cycle_prev, _closure_func(i, -1), { noremap = true })

    -- - yank (c)ode
    pop:map("n", keymaps.yank_code, function()
      local full_cont = table.concat(vim.api.nvim_buf_get_lines(pop.bufnr, 0, -1, false), "\n")
      local code = extract_code(full_cont, vim.api.nvim_win_get_cursor(pop.winid)[1])
      -- TODO: get a summary of the code (e.g. number of lines and characters)
      if code then
        require("simplegpt.utils").set_reg(code)

        -- Get a summary of the code
        local num_lines = #vim.split(code, "\n")
        local num_chars = #code
        print(string.format("Yanked Code Summary: %d lines, %d characters", num_lines, num_chars))
      end
    end, { noremap = true })

    -- Add <C-k> as a shortcut to replace the `pop.bufnr` with the code block that is closest to the cursor
    pop:map("n", keymaps.extract_code, function()
      local full_cont = table.concat(vim.api.nvim_buf_get_lines(pop.bufnr, 0, -1, false), "\n")
      local code = extract_code(full_cont, vim.api.nvim_win_get_cursor(pop.winid)[1])
      if code then
        vim.api.nvim_buf_set_lines(pop.bufnr, 0, -1, false, vim.split(code, "\n"))
        print("Replaced buffer content with the closest code block.")
      else
        print("No code block found near the cursor.")
      end
    end, { noremap = true })

    -- Add keymap to toggle dialog visibility using resume_dialog keymaps
    P( conf.get_basic_keymaps("resume_dialog"))
    pop:map("n", conf.get_basic_keymaps("resume_dialog"), function()
      print("good")
      self:toggle_window()
    end, { noremap = true })
  end

end

-- A util dialog to display information.
M.InfoDialog = utils.class("InfoDialog", M.BaseDialog)

function M.InfoDialog:ctor(context, info, filetype)
  M.InfoDialog.super.ctor(self, context)
  self.info = info
  self.filetype = filetype or 'markdown'
end

function M.InfoDialog:build()
  self.nui_obj = require("nui.popup")({
    position = "50%",
    size = {
      width = "80%",
      height = "80%",
    },
    border = {
      style = "single",
      text = {
        top = "[Info]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  })
  table.insert(self.all_pops, self.nui_obj)

  vim.api.nvim_buf_set_lines(self.nui_obj.bufnr, 0, -1, false, vim.split(self.info, "\n"))

  -- Mount the popup
  self.nui_obj:mount()

  -- Set the filetype for the buffer using the recommended method
  vim.bo[self.nui_obj.bufnr].filetype = self.filetype

  -- Focus on the new popup nui_obj
  -- This necessary due to previous exit nui may switch the focus to the from buffer
  vim.api.nvim_set_current_win(self.nui_obj.winid)

  -- Register keys for the popup
  self:register_keys()
end

-- The dialog that are able to get response to a specific PopUps
M.ChatDialog = utils.class("ChatDialog", M.BaseDialog)

function M.ChatDialog:ctor(...)
  M.ChatDialog.super.ctor(self, ...)
  self.answer_popup = nil -- the popup to display the answer
  self.full_answer = {}
  self.open_in_new_tab = require("simplegpt.conf").options.new_tab
end

function M.ChatDialog:quit()
  M.ChatDialog.super.quit(self)
  if self.open_in_new_tab then
    vim.api.nvim_command("tabclose")
  end
end

function M.ChatDialog:show()
  M.ChatDialog.super.show(self)
  -- resume some special options (I expect nui take care of it)
  M.add_winbar(self.all_pops[#self.all_pops].winid, conf.get_qa_dialog_keymaps()) -- add winbar to the last pop
end

function M.ChatDialog:call(question)
  -- NOTE: we have to initial ChatGPT.nvim at least once to make the settings effective
  -- FIXME: But if we put it in target/init.lua, it will not work in packer.
  local Settings = require("chatgpt.settings")
  if not M.init then
    local openai_params = require("chatgpt.config").options.openai_params
    Settings.get_settings_panel("chat_completions", openai_params) -- Initialize Settings.params
    M.init = true
  end

  -- Save the question to conversation history
  table.insert(self.conversation, { content = question, role = "user" })

  local messages = vim.deepcopy(self.conversation) -- Create a copy of the full conversation

  local params = vim.tbl_extend("keep", { stream = true, messages = messages }, require("chatgpt.settings").params)
  local popup = self.answer_popup -- add it to namespace to support should_stop & cb
  local current_answer = "" -- Track the complete answer

  -- Clear the answer popup buffer before starting new response
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, { "" })

  local function should_stop()
    if popup.bufnr == nil then
      -- if the window disappeared, then return False
      return true
    end
    return false
  end

  local function cb(answer, state)
    if state == "START" or state == "CONTINUE" then
      -- Accumulate the complete answer
      current_answer = current_answer .. answer

      local line_count = vim.api.nvim_buf_line_count(popup.bufnr)
      local last_line = vim.api.nvim_buf_get_lines(popup.bufnr, line_count - 1, line_count, false)[1]
      -- if answer contains "\n" or "\r", break it and creat multipe
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
    elseif state == "END" then
      -- Save the complete answer to conversation history
      table.insert(self.conversation, { content = current_answer, role = "assistant" })
    end

    if popup.border.winid ~= nil then
      popup.border:set_text("top", "State: " .. state, "center")
      popup:update_layout()
    end
  end

  require("chatgpt.api").chat_completions(params, cb, should_stop)
end

function M.ChatDialog:update_full_answer()
  self.full_answer = vim.api.nvim_buf_get_lines(self.answer_popup.bufnr, 0, -1, false)
end

function M.add_winbar(winid, keymaps)
  -- Add a winbar to the popup window to display additional information
  if vim.fn.has("nvim-0.8") == 1 then -- Ensure the version supports winbar
    local winbar_content
    local current_winbar = vim.api.nvim_win_get_option(winid, "winbar")
    if current_winbar and current_winbar ~= "" then
      winbar_content = current_winbar
    else
      winbar_content = "🎹: "
    end
    for k, v in pairs(keymaps) do
      winbar_content = winbar_content
        .. string.format(
          "%%#WinBarKey#%s %%#WinBarValue#%s%%#WinBarKey#|",
          options.ui.name_map[k] or k,
          table.concat(v, ",")
        )
    end
    vim.api.nvim_win_set_option(winid, "winbar", winbar_content)
  end
end

-- Add the following highlight groups in your Neovim configuration to customize the appearance
vim.cmd([[
  " highlight WinBarKey guifg=#FFD700 gui=bold
  highlight link WinBarKey Comment
  highlight link WinBarValue Function
]])

--- Appends content to a terminal buffer if the specified buffer is a terminal.
-- This function handles the special case of terminal buffers which require different handling
-- than regular buffers. It uses Neovim's paste mode and register manipulation to safely
-- insert content into the terminal.
--
-- @param bufnr number The buffer number to check and append to
-- @param content table A table of strings representing the content to append
-- @return boolean Returns true if the content was appended to a terminal buffer,
--         false if the buffer is not a terminal
local function append_to_terminal(bufnr, content)
  -- Check if buffer is a terminal and append content if it is
  if vim.api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
    -- Save current window and switch to terminal buffer
    vim.api.nvim_set_current_win(vim.fn.bufwinid(bufnr))

    -- Some terminals use vim mode. So we go to insert mode by 'i' first, then use <C-u> to remove previous content
    local keys = vim.api.nvim_replace_termcodes('ii<C-u>', true, false, true)

    vim.api.nvim_feedkeys(keys, "t", true)
    -- Convert the content table into a single string with newlines
    local content_str = table.concat(content, "\n")

    -- Save the original value of register 'z' to restore it later
    local original_z = vim.fn.getreg("z")

    -- Enable paste mode to prevent terminal from interpreting special characters
    vim.opt.paste = true

    -- Store the content in register 'z' for pasting
    vim.fn.setreg("z", content_str)

    -- Use the "zp" command to paste the content into the terminal
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<c-\\><c-n>"zp', true, false, true), "t", true)

    -- Disable paste mode after pasting
    vim.opt.paste = false

    -- Restore the original value of register 'z' after a short delay to ensure the paste operation completes
    vim.defer_fn(function()
      vim.fn.setreg('z', original_z)
    end, 100)

    return true
  end
  return false
end

function M.ChatDialog:register_keys(exit_callback)
  M.ChatDialog.super.register_keys(self, exit_callback)

  M.add_winbar(self.all_pops[#self.all_pops].winid, conf.get_qa_dialog_keymaps()) -- add winbar to the last pop
  for _, pop in ipairs(self.all_pops) do
    -- Append full answer: append the response to original buffer
    pop:map("n", options.dialog.keymaps.append_keys, function()
      -- Update full_answer before exit to ensure buffer exists
      self:update_full_answer()

      self:quit() -- callback may open new windows. So we quit the windows before callback
      if exit_callback ~= nil then
        exit_callback()
      end

      local from_bufnr = self.context["from_bufnr"]
      local last_line = self.context.visual_selection_or_current_line["end"].row

      -- Handle terminal or normal buffer
      if not append_to_terminal(from_bufnr, self.full_answer) then
        -- For normal buffers, insert the lines
        vim.api.nvim_buf_set_lines(from_bufnr, last_line, last_line, false, self.full_answer)
      end
    end, { noremap = true })

    -- replace the selected buffer (or current line) with the response
    pop:map("n", options.dialog.keymaps.replace_keys, function()
      -- Update full_answer before exit to ensure buffer exists
      self:update_full_answer()

      -- TODO: we can support only inserting the code. It may bring more conveniences.

      self:quit() -- callback may open new windows. So we quit the windows before callback
      if exit_callback ~= nil then
        exit_callback()
      end

      local from_bufnr = self.context["from_bufnr"]

      -- Handle terminal buffer first
      if append_to_terminal(from_bufnr, self.full_answer) then
        return
      end

      -- Handle normal buffers
      if self.context.replace_target == "visual" then
        -- Get the range of lines to replace
        local start_line, end_line, mode
        start_line, end_line, mode =
          self.context.visual_selection_or_current_line.start.row,
          self.context.visual_selection_or_current_line["end"].row,
          self.context.visual_selection_or_current_line.mode
        -- Replace the lines in from_bufnr with `self.full_answer`
        if mode == "V" then
          -- Replace the entire lines in visual selection with `self.full_answer`
          vim.api.nvim_buf_set_lines(from_bufnr, start_line - 1, end_line, false, self.full_answer)
        elseif mode == "v" then
          -- Keep the content before and after visual selection
          local start_col = self.context.visual_selection_or_current_line.start.col
          local end_col = self.context.visual_selection_or_current_line["end"].col
          local current_line = vim.api.nvim_buf_get_lines(from_bufnr, start_line - 1, start_line, false)[1]
          local before_selection = current_line:sub(1, start_col - 1)
          local after_selection = current_line:sub(end_col + 1)
          local new_line = before_selection .. table.concat(self.full_answer, "\n") .. after_selection
          -- Replace the selected text with the new content
          local new_lines = vim.split(new_line, "\n") -- Split the new_line into multiple lines if necessary
          vim.api.nvim_buf_set_lines(from_bufnr, start_line - 1, start_line, false, new_lines)
        end
      elseif self.context.replace_target == "file" then
        vim.api.nvim_buf_set_lines(from_bufnr, 0, -1, false, self.full_answer)
      end
    end, { noremap = true })

    -- Yank keys
    pop:map("n", options.dialog.keymaps.yank_keys, function()
      -- Update full_answer before exit to ensure buffer exists
      self:update_full_answer()
      require("simplegpt.utils").set_reg(table.concat(self.full_answer, "\n"))
      print("answer Yanked")
    end, { noremap = true })

    -- Add key mapping for continuing conversation
    pop:map("n", options.dialog.keymaps.chat_keys, function()
      local Input = require("nui.input")
      local event = require("nui.utils.autocmd").event

      local input = Input({
        position = "50%",
        size = { width = 60 },
        border = {
          style = "single",
          text = {
            top = "[Chat to Continue Conversation/Instruction Edit]",
            top_align = "center",
          },
        },
        win_options = {
          winhighlight = "Normal:Normal,FloatBorder:Normal",
        },
        zindex = 70, -- Add higher zindex to ensure it appears on top
      }, {
        prompt = "> ",
        on_close = function()
          print("Input Cancelled")
        end,
        on_submit = function(value)
          if value and value ~= "" then
            -- Call API with the new input
            self:call(value)
          end
        end,
      })
      -- register exit keys same as the config
      for _, key in ipairs(options.dialog.keymaps.exit_keys) do
        input:map("n", key, function()
          input:unmount()
        end, { noremap = true, silent = true })
      end

      -- mount/open the component
      input:mount()

      -- unmount component when cursor leaves buffer
      input:on(event.BufLeave, function()
        input:unmount()
      end)
    end, { noremap = true })

    -- search and replace
    pop:map("n", options.dialog.keymaps.search_replace, function()
      -- Update full_answer before exit to ensure buffer exists
      self:update_full_answer()
      local sr_blocks = search_replace.extract_blocks(self.answer_popup.bufnr)
      self:quit()
      search_replace.apply_blocks(self.context.from_bufnr, sr_blocks)
    end, { noremap = true })
  end

end

return M
