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
      -- open a new tab and load current buffer
      local bufname = vim.api.nvim_buf_get_name(context.from_bufnr)
      if bufname == "" then
        vim.api.nvim_command('tabnew')
        local cur_buf = vim.api.nvim_get_current_buf() -- Close the newly created empty buffer
        vim.api.nvim_command('b ' .. context.from_bufnr)
        vim.api.nvim_command('bdelete ' .. cur_buf)
      else
        -- Open a new tab and switch to the buffer
        vim.api.nvim_command('tabnew ' .. bufname)
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
