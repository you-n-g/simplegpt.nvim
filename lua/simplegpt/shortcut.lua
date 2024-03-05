-- We should add some shortcuts for nvim telescope

-- TODO: require config

local loader = require("simplegpt.loader")

M = {}

function M.build_func(target)
  return function()
    local rqa = require("simplegpt.tpl").RegQAUI()
    -- the context when building the QA builder
    local context = {
      filetype = vim.bo.filetype,
      rqa = rqa,
      from_bufnr = vim.api.nvim_get_current_buf(),
    }
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
