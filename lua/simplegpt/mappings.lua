local M = {}
local loader = require("simplegpt.loader")
local tpl = require("simplegpt.tpl")
local target = require("simplegpt.target")
local shortcut = require("simplegpt.shortcut")

-- This function sets up the main key mappings for the application.
-- It maps keys to basic functions such as loading/dumping/editing registers, sending to basic targets
function M.setup_main_mappings()
  vim.keymap.set(
    "n",
    "<m-g><m-g>l",
    loader.tele_load_reg,
    { noremap = true, silent = true, desc = "load registers" }
  )
  vim.keymap.set(
    "n",
    "<m-g><m-g>D",
    loader.input_dump_name,
    { noremap = true, silent = true, desc = "dump registers" }
  )
  vim.keymap.set({ "n", "v" }, "<m-g><m-g>e", function()
    local rqa = tpl.RegQAUI()
    rqa:build()
  end, { noremap = true, silent = true, desc = "edit registers" })
  vim.keymap.set(
    { "n", "v" },
    "<m-g><m-g>s",
    shortcut.build_func("clipboard"),
    { noremap = true, silent = true, desc = "send question2clipboard" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<m-g><m-g>c",
    shortcut.build_func("chat"),
    { noremap = true, silent = true, desc = "send question2ChatGPT" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<m-g><m-g>r",
    shortcut.build_func("popup"),
    { noremap = true, silent = true, desc = "send to get direct response" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<m-g><m-g>d",
    shortcut.build_func("diff"),
    { noremap = true, silent = true, desc = "send to get response with diff" }
  )
  -- utils
  vim.keymap.set(
    { "n", "v" },
    "<m-g><m-g>R",
    target.resume_last_dialog,
    { noremap = true, silent = true, desc = "resume last dialog" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<m-g><m-g>p",
    tpl.repo_load_file,
    { noremap = true, silent = true, desc = "load current file to reg" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<m-g><m-g>P",
    tpl.repo_append_file,
    { noremap = true, silent = true, desc = "append current file to reg" }
  )
end

function M.setup()
  M.setup_main_mappings()
  shortcut.register_shortcuts()
  -- TODO: if `which-key` is installed
  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.add({
      { "<m-g><m-g>", group = "Advanced" },
      { "<m-g>", group = "🤏SimpleGPT" },
    })
  end
end

return M
