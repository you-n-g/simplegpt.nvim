-- Chat in current buffer.
-- This module provides chat functionality within the current buffer.
-- Three types of messages are supported:
-- - System messages (💻): When used as the first message, it provides context/instructions
--   When used later in the conversation, it's treated as a user message
-- - User messages (👤): Regular user input to the AI
-- - AI messages (🤖): AI-generated responses
--
-- These emoji markers are configurable in conf.lua
local dialog = require("simplegpt.dialog")
local conf = require("simplegpt.conf")

local M = {}

-- Get emoji-to-role mapping
function M.get_emoji_role_maps()
  -- This function creates two mapping tables:
  -- 1. emoji_to_role: Maps emoji markers to their roles
  -- 2. role_to_emoji: Maps roles to their emoji markers
  local emoji_to_role = {
    [conf.options.buffer_chat.user_emoji] = "user",
    [conf.options.buffer_chat.ai_emoji] = "assistant",
    [conf.options.buffer_chat.system_emoji] = "system",
  }

  local role_to_emoji = {
    user = conf.options.buffer_chat.user_emoji,
    assistant = conf.options.buffer_chat.ai_emoji,
    system = conf.options.buffer_chat.system_emoji,
  }

  return emoji_to_role, role_to_emoji
end

--- Extract and parse messages from buffer content into a structured format.
-- This function analyzes buffer content line by line to identify and categorize conversation messages
-- based on emoji markers. It handles special cases like system messages and maintains the structure
-- of multiline messages.
--
-- @param buffer_content string The raw text content from the buffer to be parsed
-- @return table An array of message objects, each containing:
--   - role: string ("user", "assistant", or "system")
--   - content: string (the message text without the emoji marker)
--   - start_line: number (the line number where this message starts)
--
-- Special behaviors:
-- 1. System emoji (💻) is treated as "system" role only when it appears in the first message
-- 2. System emoji in later messages is interpreted as "user" role
-- 3. If no emojis are found, the entire content is treated as a single user message
-- 4. Consecutive lines without emoji markers are grouped with the preceding message
function M.extract_messages(buffer_content)
  local conversation_lines = vim.split(buffer_content, "\n")
  local extracted_messages = {}
  local current_role = nil
  local current_start_line = nil
  local current_content = {}

  -- Get emoji-to-role mapping
  local emoji_to_role, _ = M.get_emoji_role_maps()

  -- Track if this is the first message we're seeing
  local is_first_message = true

  for lino, line in ipairs(conversation_lines) do
    local matched = false

    -- Check for emoji markers at the start of lines
    for emoji, role in pairs(emoji_to_role) do
      local content_match = line:match("^" .. emoji .. "%s?(.*)")
      if content_match then
        -- Save previous message if any
        if current_role then
          table.insert(
            extracted_messages,
            { role = current_role, content = table.concat(current_content, "\n"), start_line = current_start_line }
          )
        end

        -- System emoji treatment depends on position
        if role == "system" and not is_first_message then
          current_role = "user" -- System emoji treated as user when not first
        else
          current_role = role
        end
        current_start_line = lino

        current_content = { content_match }
        is_first_message = false
        matched = true
        break
      end
    end

    -- If no emoji match found, continue previous message
    if not matched and current_role then
      table.insert(current_content, line)
    end
  end

  -- Add the last message if any
  if current_role and #current_content > 0 then
    table.insert(
      extracted_messages,
      { role = current_role, content = table.concat(current_content, "\n"), start_line = current_start_line }
    )
  end

  -- If no messages were extracted or no conversation detected, create a default message
  if #extracted_messages == 0 then
    -- Create a default message treating all content as user input
    return {
      { role = "user", content = buffer_content, start_line = 1 },
    }
  end

  return extracted_messages
end

--- Ensures all messages in the buffer have appropriate emoji markers.
-- This function examines each message in the buffer and adds the correct emoji marker
-- to the beginning of any message that doesn't already have one. It preserves the content
-- of the messages while enforcing consistent formatting.
--
-- @param buf number The buffer handle to modify
-- @param messages table Array of message objects from extract_messages function, each containing:
--   - role: string ("user", "assistant", or "system")
--   - content: string (the message text)
--   - start_line: number (the line number where this message starts)
--
-- Side effects:
-- - Modifies the buffer content by adding emoji markers where needed
-- - Only updates the buffer if at least one line was modified
function M.reformat_buffer(buf, messages)
  -- If no messages, return early
  if not messages or #messages == 0 then
    return
  end

  -- Get emoji-to-role and role-to-emoji mappings
  local emoji_to_role, role_to_emoji = M.get_emoji_role_maps()

  -- Get the buffer lines
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local modified = false

  -- Process each message
  for _, msg in ipairs(messages) do
    local role = msg.role
    local start_line = msg.start_line or 1

    -- Skip if start_line is out of range
    if start_line <= #lines then
      -- Get emoji for this message's role
      local emoji = role_to_emoji[role]

      -- Check if line already starts with an emoji
      local line = lines[start_line]
      local has_emoji = false

      for e, _ in pairs(emoji_to_role) do
        if line:match("^" .. e) then
          has_emoji = true
          break
        end
      end

      -- If line doesn't start with emoji, add the appropriate one
      if not has_emoji and emoji then
        lines[start_line] = emoji .. " " .. line
        modified = true
      end
    end
  end

  -- Check if buffer starts with a system prompt
  local has_system_prompt = false
  if #messages > 0 then
    has_system_prompt = messages[1].role == "system"
  end

  -- If no system prompt, add a default one at the top
  if not has_system_prompt then
    local system_emoji = role_to_emoji["system"]
    local default_prompt = conf.options.buffer_chat.default_system_prompt
    table.insert(lines, 1, system_emoji .. " " .. default_prompt)

    -- Add an empty line after the system prompt for better readability
    table.insert(lines, 2, "")
    modified = true
  end

  -- Update buffer if any changes were made
  if modified then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end
end

function M.set_style(buf)
  local messages = M.extract_messages(table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"))
  -- Use Neovim's UI to add a line marker to the start of each message
  -- Create a single namespace for all message markers
  local ns = vim.api.nvim_create_namespace("simplegpt_msg_marker_and_spinner")

  -- Clear all existing markers first
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  for _, msg in ipairs(messages) do
    local start_line = msg.start_line or 1
    -- Add a vim sign/mark at the start of each message line
    if start_line >= 1 then
      -- Place the extmark ONLY if the line exists
      local total_lines = vim.api.nvim_buf_line_count(buf)
      if start_line <= total_lines then
        vim.api.nvim_buf_set_extmark(buf, ns, start_line - 1, 0, {
          sign_text = "▶",
          sign_hl_group = "Question", -- You can customize this group
          priority = 10,
        })
      end
    end
  end
end

-- Define a CompletionState class to track chat completion state for a buffer
local CompletionState = require("simplegpt.utils").class("CompletionState")

-- Constructor for CompletionState
function CompletionState:ctor(buf_id)
  self.buf_id = buf_id
  self.running = false
  self.spinner = nil
  self.spinner_line = nil
end

-- Check if completion is running
function CompletionState:is_running()
  return self.running
end

-- Create and start a spinner at the specified line
function CompletionState:start_spinner(line)
  -- Create a spinner instance
  self.spinner = require("simplegpt.spinner").Spinner()
  self.spinner_line = line
  self.running = true

  -- Start the spinner immediately and force UI update
  self.spinner:start(self.buf_id, line)
  vim.cmd("redraw")

  return self.spinner
end

-- Stop a completion
function CompletionState:stop()
  vim.api.nvim_exec_autocmds("User", { pattern = require("avante.llm").CANCEL_PATTERN }) -- avante's mechanism to cancel the request

  if self.spinner then
    self.spinner:complete()
  end
  self.running = false
  self.spinner = nil
  self.spinner_line = nil
end

-- Table to store state managers for each buffer
M.buffer_states = {}

-- Get or create a completion state for a buffer
function M.get_buffer_state(buf_id)
  if not M.buffer_states[buf_id] then
    M.buffer_states[buf_id] = CompletionState(buf_id)
  end
  return M.buffer_states[buf_id]
end

-- Simple function to generate the next response and append it to the buffer
function M.buf_chat_complete()
  -- Get buffer information
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  -- Get the state for this buffer
  local buf_state = M.get_buffer_state(buf)

  -- Check if a completion is already running for this buffer and abort it if needed
  if buf_state:is_running() then
    buf_state:stop()
    return
  end

  -- Lines already moved to previous code block

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local content = table.concat(lines, "\n")

  -- Extract messages from buffer content
  local messages = M.extract_messages(content)
  M.reformat_buffer(buf, messages)
  -- NOTE: after reformat, the (system) messages may change
  lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  messages = M.extract_messages(table.concat(lines, "\n"))

  -- Get role-to-emoji mapping
  local _, role_to_emoji = M.get_emoji_role_maps()

  -- Add AI emoji at the end of buffer
  local line_count = #lines

  -- Make sure we have a blank line before adding the AI emoji
  if line_count > 0 and lines[line_count]:match("^%s*$") == nil then
    vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, { "" })
    line_count = line_count + 1
  end

  -- Add AI emoji
  vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, { role_to_emoji.assistant .. " " })
  M.set_style(buf)

  -- Create and start the spinner in the buffer state
  buf_state:start_spinner(vim.api.nvim_buf_line_count(buf) - 1)

  -- Streaming callback function with access to the spinner
  local function cb(answer, state)
    -- Accumulate complete answer
    if answer and (state == "START" or state == "CONTINUE") then
      -- Add answer lines to buffer
      local ans_lines = vim.split(answer, "\n")
      for i, line in ipairs(ans_lines) do
        if i == 1 then
          -- Append to the last line
          local last_line_num = vim.api.nvim_buf_line_count(buf) - 1
          local last_line = vim.api.nvim_buf_get_lines(buf, last_line_num, last_line_num + 1, false)[1]
          vim.api.nvim_buf_set_lines(buf, last_line_num, last_line_num + 1, false, { last_line .. line })
        else
          -- Add new line
          vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
        end
      end

      -- Move cursor to the last line
      local new_line_count = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_win_set_cursor(win, { new_line_count, 0 })
    elseif state == "END" then
      -- When response is complete, add user prompt for next message
      vim.schedule(function()
        -- Add user emoji for next message
        local line_cnt = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_buf_set_lines(buf, line_cnt, line_cnt, false, { "", role_to_emoji.user .. " " })

        -- Move cursor after the user emoji for convenient input
        local new_line_count = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_win_set_cursor(win, { new_line_count, #role_to_emoji.user + 2 }) -- Position after emoji and space

        -- Reset active completion state for this buffer
        buf_state:stop()
      end)
      -- State cleanup will handle the spinner
    elseif state == "ERROR" then
      vim.notify(answer)
    end
  end

  -- Schedule the API call to happen after UI updates are processed
  vim.schedule(function()
    dialog.chat_completions(messages, cb, conf.options.buffer_chat.provider)
  end)
  vim.bo[buf].filetype = "markdown"
end

-- Create a buffer with formatted chat messages
-- @param messages table: Array of message objects with role and content fields
-- @param add_prompt boolean: Whether to add a final user prompt line
-- @return number: The buffer number of the created buffer
function M.create_chat_buffer(messages, add_prompt)
  -- Default add_prompt to true if not specified
  if add_prompt == nil then
    add_prompt = true
  end

  -- Get role-to-emoji mapping
  local _, role_to_emoji = M.get_emoji_role_maps()

  -- Create a new buffer
  vim.cmd("enew")
  local buf = vim.api.nvim_get_current_buf()
  local buflines = {}

  -- Helper function to handle multiline content
  local function add_content_with_emoji(emoji, content)
    -- Split content by newlines
    local lines = vim.split(content, "\n")
    if #lines == 0 then
      return
    end

    -- First line gets the emoji
    table.insert(buflines, emoji .. " " .. lines[1])

    -- Subsequent lines are added without emoji
    for i = 2, #lines do
      table.insert(buflines, lines[i])
    end
  end

  -- Convert conversation to buffer chat format with emojis
  for _, msg in ipairs(messages) do
    if msg.role == "system" then
      add_content_with_emoji(role_to_emoji.system, msg.content)
    elseif msg.role == "user" then
      table.insert(buflines, "")
      add_content_with_emoji(role_to_emoji.user, msg.content)
    elseif msg.role == "assistant" then
      table.insert(buflines, "")
      add_content_with_emoji(role_to_emoji.assistant, msg.content)
    end
  end

  -- Add user prompt at the end if requested
  if add_prompt then
    table.insert(buflines, "")
    table.insert(buflines, role_to_emoji.user .. " ")
  end

  -- Set the buffer lines
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, buflines)

  -- Move cursor to the end
  if add_prompt then
    local new_line_count = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(0, { new_line_count, #role_to_emoji.user + 2 })
  end
  -- set filetype to markdown
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  return buf
end

return M
