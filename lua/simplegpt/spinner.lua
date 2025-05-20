-- spinner.lua
-- A module for creating and managing spinning animations in Neovim buffers

local utils = require("simplegpt.utils")

local M = {}

-- Define the Spinner class using the class system
local Spinner = utils.class("Spinner")

-- Constructor for the Spinner class
function Spinner:ctor(opts)
  opts = opts or {}
  
  -- Default spinner frames (can be overridden)
  self.frames = opts.frames or { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  -- Default complete indicator
  self.complete_indicator = opts.complete_indicator or "▶ "
  -- Default interval between frames (in milliseconds)
  self.interval = opts.interval or 100
  -- Default highlight group
  self.highlight = opts.highlight or "Question"
  -- Internal state
  self.current_frame = 1
  self.timer = nil
  -- very important to be same name space as msg marker.
  self.namespace = vim.api.nvim_create_namespace(opts.namespace_name or "simplegpt_msg_marker_and_spinner")
  self.buffer = nil
  self.line = nil
  self.is_spinning = false
  self.priority = opts.priority or 10
end

-- Start the spinner at the given buffer and line
function Spinner:start(buffer, line)
  self.buffer = buffer
  self.line = line
  self.is_spinning = true
  
  -- Stop any existing timer
  if self.timer then
    self.timer:stop()
  end
  
  -- Create a new timer for animation
  self.timer = vim.loop.new_timer()
  
  -- Start the timer to update frames
  self.timer:start(0, self.interval, vim.schedule_wrap(function()
    self:update()
  end))
  
  -- Immediately draw the first frame
  self:update()
  
  return self
end

-- Update the spinner animation frame
function Spinner:update()
  -- Check if buffer is still valid
  if not vim.api.nvim_buf_is_valid(self.buffer) then
    self:stop()
    return
  end
  
  -- If not spinning, no need to update
  if not self.is_spinning then
    return
  end
  
  -- Move to the next frame
  self.current_frame = (self.current_frame % #self.frames) + 1
  
  -- Update the extmark with the current spinner frame as a sign
  vim.api.nvim_buf_clear_namespace(self.buffer, self.namespace, self.line, self.line + 1)
  vim.api.nvim_buf_set_extmark(self.buffer, self.namespace, self.line, 0, {
    sign_text = self.frames[self.current_frame],
    sign_hl_group = self.highlight,
    priority = self.priority
  })
end

-- Stop the spinner animation
function Spinner:stop()
  if self.timer then
    self.timer:stop()
    self.timer = nil
  end
  self.is_spinning = false
end

-- Mark the spinner as complete (changes to the complete indicator)
function Spinner:complete()
  self:stop()
  
  if vim.api.nvim_buf_is_valid(self.buffer) and self.line ~= nil then
    vim.api.nvim_buf_clear_namespace(self.buffer, self.namespace, self.line, self.line + 1)
    vim.api.nvim_buf_set_extmark(self.buffer, self.namespace, self.line, 0, {
      sign_text = "▶",
      sign_hl_group = self.highlight,
      priority = self.priority
    })
  end
end

-- Clear the spinner from the buffer
function Spinner:clear()
  self:stop()
  
  if vim.api.nvim_buf_is_valid(self.buffer) and self.line ~= nil then
    vim.api.nvim_buf_clear_namespace(self.buffer, self.namespace, self.line, self.line + 1)
  end
end

-- Export the Spinner class for potential inheritance
M.Spinner = Spinner

return M
