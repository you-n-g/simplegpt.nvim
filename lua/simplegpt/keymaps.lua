local M = {}
local loader = require("simplegpt.loader")
local tpl = require("simplegpt.tpl")
local target = require("simplegpt.target")
local shortcut = require("simplegpt.shortcut")
local conf = require("simplegpt.conf")
local options = conf.options

-- This function sets up the main keymaps for the application.
-- It maps keys to basic functions such as loading/dumping/editing registers, sending to basic targets
local prefix = options.keymaps.prefix
local keymaps = options.keymaps

function M.setup_main_keymaps()

  vim.keymap.set(
    "n",
    conf.get_basic_keymaps("load_reg"),
    loader.tele_load_reg,
    { noremap = true, silent = true, desc = "load registers" }
  )
  vim.keymap.set(
    "n",
    conf.get_basic_keymaps("dump_reg"),
    loader.input_dump_name,
    { noremap = true, silent = true, desc = "dump registers" }
  )
  vim.keymap.set({ "n", "v" },
    conf.get_basic_keymaps("edit_reg"), function()
    local rqa = tpl.RegQAUI(shortcut.build_context())
    rqa:build()
  end, { noremap = true, silent = true, desc = "edit registers" })
  vim.keymap.set(
    { "n", "v" },
    conf.get_basic_keymaps("send_clipboard"),
    shortcut.build_func("clipboard"),
    { noremap = true, silent = true, desc = "send question2clipboard" }
  )
  vim.keymap.set(
    { "n", "v" },
    conf.get_basic_keymaps("send_chat"),
    shortcut.build_func("chat"),
    { noremap = true, silent = true, desc = "send question to chat" }
  )
  vim.keymap.set(
    { "n", "v" },
    conf.get_basic_keymaps("send_popup"),
    shortcut.build_func("popup"),
    { noremap = true, silent = true, desc = "send to get direct response" }
  )
  vim.keymap.set(
    { "n", "v" },
    conf.get_basic_keymaps("send_diff"),
    shortcut.build_func("diff"),
    { noremap = true, silent = true, desc = "send to get response with diff" }
  )
  vim.keymap.set(
    { "n", "v", "t" },
    conf.get_basic_keymaps("resume_dialog"),
    target.resume_last_dialog,
    { noremap = true, silent = true, desc = "resume last dialog" }
  )
  vim.keymap.set(
    { "n", "v" },
    conf.get_basic_keymaps("load_file"),
    tpl.repo_load_file,
    { noremap = true, silent = true, desc = "load current file to reg" }
  )
  vim.keymap.set(
    { "n", "v" },
    conf.get_basic_keymaps("append_file"),
    tpl.repo_append_file,
    { noremap = true, silent = true, desc = "append current file to reg" }
  )
  vim.keymap.set(
    { "n", "v" },
    conf.get_basic_keymaps("chat_complete"),
    require"simplegpt.buf_chat".buf_chat_complete,
    { noremap = true, silent = true, desc = "Buffer chat or stop streaming" }
  )
end

function M.setup()
  M.setup_main_keymaps()
  shortcut.register_shortcuts()
  -- TODO: if `which-key` is installed
  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.add({
      { prefix, group = "🤏BasicOps" },
      { options.keymaps.shortcuts.prefix, group = "🤏Shortcuts" },
    })
  end
end

return M
