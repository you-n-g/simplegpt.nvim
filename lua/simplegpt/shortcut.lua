-- We should add some shortcuts for nvim telescope

-- TODO: require config

local loader = require("simplegpt.loader")

M = {}

function M.build_func(target)
  return function(context_extra)
    local rqa = require("simplegpt.tpl").RegQAUI()
    -- the context when building the QA builder
    -- TODO: open a new tab and load current buffer
    local context = {
      filetype = vim.bo.filetype,
      rqa = rqa,
      from_bufnr = vim.api.nvim_get_current_buf(),
      replace_target = "visual", -- what the response is expected to replace (visual, file)
    }
    if context_extra ~= nil then
      context = vim.tbl_extend("force", context, context_extra)
    end

    context.cursor_pos = vim.api.nvim_win_get_cursor(require"simplegpt.utils".get_win_of_buf(context.from_bufnr))
    context.visual_selection_or_cur_line = require"simplegpt.utils".get_visual_selection()

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
  local shortcuts = require"simplegpt.conf".options.keymaps.shortcuts
  for _, s in ipairs(shortcuts.list) do
    if s.key == nil then
      s.key = shortcuts.prefix .. s.suffix
    end
    vim.keymap.set(s.mode, s.key, function()
      loader.load_reg(s.tpl)

      -- Support setting extra reg when loading template
      if s.reg ~= nil then 
        for reg, value in pairs(s.reg) do
          -- Check if `vim.fn.getreg(reg)` contains `value` then skip setting it.
          -- Substring indicates contains. We do not need an exact match.
          local current_value = vim.fn.getreg(reg)
          if not string.find(current_value, value, 1, true) then
            vim.fn.setreg(reg, value)
          else
            -- NOTE: In case of overwriting user's customized information;
            print("Register `" .. reg .. "` already contains the value, skip setting")
          end
        end
      end
      M.build_func(s.target)(s.context)
    end, s.opts)
  end
end


return M
