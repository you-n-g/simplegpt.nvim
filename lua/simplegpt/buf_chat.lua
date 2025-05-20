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

-- Extract messages from buffer content
-- This function analyzes buffer content and tries to identify conversation messages
function M.extract_messages(buffer_content, filetype)
  local conversation_lines = vim.split(buffer_content, "\n")
  local extracted_messages = {}
  local current_role = nil
  local current_content = {}

  -- Get emoji-to-role mapping
  local emoji_to_role, _ = M.get_emoji_role_maps()

  -- Track if this is the first message we're seeing
  local is_first_message = true

  for _, line in ipairs(conversation_lines) do
    local matched = false

    -- Check for emoji markers at the start of lines
    for emoji, role in pairs(emoji_to_role) do
      local content_match = line:match("^" .. emoji .. "%s?(.*)")
      if content_match then
        -- Save previous message if any
        if current_role then
          table.insert(extracted_messages, { role = current_role, content = table.concat(current_content, "\n") })
        end

        -- System emoji treatment depends on position
        if role == "system" and not is_first_message then
          current_role = "user" -- System emoji treated as user when not first
        else
          current_role = role
        end

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
    table.insert(extracted_messages, { role = current_role, content = table.concat(current_content, "\n") })
  end

  -- If no messages were extracted or no conversation detected, create a default message
  if #extracted_messages == 0 then
    -- Create a default message treating all content as user input
    return {
      { role = "user", content = buffer_content },
    }
  end

  return extracted_messages
end

-- Simple function to generate the next response and append it to the buffer
function M.buf_chat_complete()
  -- Get buffer information
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local content = table.concat(lines, "\n")
  local filetype = vim.bo[buf].filetype or ""

  -- Extract messages from buffer content
  local messages = M.extract_messages(content, filetype)

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

  -- Streaming callback function
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
        local line_count = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, { "", role_to_emoji.user .. " " })

        -- Move cursor after the user emoji for convenient input
        local new_line_count = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_win_set_cursor(win, { new_line_count, #role_to_emoji.user + 2 }) -- Position after emoji and space
      end)
    end
  end

  -- Callback for stopping generation
  local function should_stop()
    -- Stop generation if buffer is no longer valid
    return not vim.api.nvim_buf_is_valid(buf)
  end

  -- Call LLM to start generation
  vim.notify("Chatting with buffer, please wait...", vim.log.levels.INFO)
  dialog.chat_completions(messages, cb, should_stop)
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

