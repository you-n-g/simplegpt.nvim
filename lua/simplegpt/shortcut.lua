-- We should add some shortcuts for nvim telescope

-- TODO: require config

local loader = require("simplegpt.loader")

M = {}

function M.build_context(context_extra)
  ---@class DialogContext
  local context = {
    filetype = vim.bo.filetype,
    from_bufnr = vim.api.nvim_get_current_buf(),
    replace_target = "visual", -- what the response is expected to replace (visual, file)
  }
  if context_extra ~= nil then
    context = vim.tbl_extend("force", context, context_extra)
  end

  context.cursor_pos = vim.api.nvim_win_get_cursor(require"simplegpt.utils".get_win_of_buf(context.from_bufnr))
  context.visual_selection = require"simplegpt.utils".get_visual_selection(true)
  context.visual_selection_or_current_line = require"simplegpt.utils".get_visual_selection()  -- replace and append action will use this if no visual
  return context
end

function M.build_func(target)
  return function(context_extra)
    local context = M.build_context(context_extra)
    -- TODO: open a new tab and load current buffer
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

    context['rqa'] = require("simplegpt.tpl").RegQAUI(context)
    -- the context when building the QA builder
    -- rqa will build the question and send to the target
    context['rqa']:build(require("simplegpt.target." .. target).build_q_handler(context))
  end
end

local function register_shortcut_dict(shortcut_dict)
  for key, s in pairs(shortcut_dict) do
    vim.keymap.set(s.mode, key, function()
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

function M.register_shortcuts()
  local keymaps = require"simplegpt.conf".options.keymaps
  local shortcuts = keymaps.shortcuts
  local shortcut_dict = {}
  for _, s in ipairs(shortcuts.list) do
    local key = s.key or (shortcuts.prefix and shortcuts.prefix .. s.suffix)
    if key then
      shortcut_dict[key] = s
    end
  end
  register_shortcut_dict(shortcut_dict)

  register_shortcut_dict(keymaps.custom_shortcuts)
end


return M
