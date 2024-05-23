-- We should add some shortcuts for nvim telescope

-- TODO: require config

local loader = require("simplegpt.loader")

M = {}

function M.build_func(target)
  return function()
    local rqa = require("simplegpt.tpl").RegQAUI()
    -- the context when building the QA builder
    -- TODO: open a new tab and load current buffer
    local context = {
      filetype = vim.bo.filetype,
      rqa = rqa,
      from_bufnr = vim.api.nvim_get_current_buf(),
    }
    context.cursor_pos = vim.api.nvim_win_get_cursor(require"simplegpt.utils".get_win_of_buf(context.from_bufnr))
    context.visual_selection = require"simplegpt.utils".get_visual_selection()

    if require"simplegpt.conf".options.new_tab then
      -- NOTE: it will fail to run tabedit if we are in a unnamed buffer
      -- Attempt to execute the command in a protected call
      local success, errmsg = pcall(vim.api.nvim_command, 'tabedit #' .. context.from_bufnr)

      -- Check if the command failed
      if not success then
        -- If an error occurred, print the error message (optional) and open a new tab
        print("Error opening tab with buffer: " .. errmsg)  -- Optional: for debugging
        vim.api.nvim_command('tabnew')  -- Open a new tab without specifying a buffer
      end
    end

    -- rqa will build the question and send to the target
    rqa:build(require("simplegpt.target." .. target).build_q_handler(context))
  end
end

M.register_shortcuts = function()
  for _, s in ipairs(require"simplegpt.conf".options.shortcuts) do
    vim.keymap.set(s.mode, s.key, function()
      loader.load_reg(s.tpl)
      M.build_func(s.target)()
    end, s.opts)
  end
end


return M
