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

-- Make sure we have `key`attribute in each element of `shortcut_list`
local function register_shortcut_list(shortcut_list)
  for _, s in ipairs(shortcut_list) do
    vim.keymap.set(s.mode, s.key, function()
      loader.load_reg(s.tpl)

      -- Support setting extra reg when loading template
      if s.reg ~= nil then
        for reg, value in pairs(s.reg) do
          -- Sometime, the value depends on the simplegpt context.
          -- but we can't access simplegpt in config. So we delay the building of the value as as a function
          if type(value) == "function" then
            value = value()
          end
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

local function update_shortcut_list(shortcut_list)
  local keymaps = require"simplegpt.conf".options.keymaps
  local prefix = keymaps.shortcuts.prefix
  for _, s in ipairs(shortcut_list) do
    s.key = s.key or (prefix and prefix .. s.suffix)
  end
end

function M.register_shortcuts()
  local keymaps = require"simplegpt.conf".options.keymaps
  local shortcut_list = keymaps.shortcuts.list
  update_shortcut_list(shortcut_list)
  register_shortcut_list(shortcut_list)

  update_shortcut_list(keymaps.custom_shortcuts)
  register_shortcut_list(keymaps.custom_shortcuts)
end


return M
