local M = {}
local loader = require("simplegpt.loader")
local tpl = require("simplegpt.tpl")
local target = require("simplegpt.target")
local shortcut = require("simplegpt.shortcut")
local options = require("simplegpt.conf").options

-- This function sets up the main keymaps for the application.
-- It maps keys to basic functions such as loading/dumping/editing registers, sending to basic targets
local prefix = options.keymaps.prefix
local keymaps = options.keymaps

function M.setup_main_keymaps()
  vim.keymap.set(
    "n",
    keymaps.load_reg.key or prefix .. keymaps.load_reg.suffix,
    loader.tele_load_reg,
    { noremap = true, silent = true, desc = "load registers" }
  )
  vim.keymap.set(
    "n",
    keymaps.dump_reg.key or prefix .. keymaps.dump_reg.suffix,
    loader.input_dump_name,
    { noremap = true, silent = true, desc = "dump registers" }
  )
  vim.keymap.set({ "n", "v" },
    keymaps.edit_reg.key or prefix .. keymaps.edit_reg.suffix, function()
    local rqa = tpl.RegQAUI()
    rqa:build()
  end, { noremap = true, silent = true, desc = "edit registers" })
  vim.keymap.set(
    { "n", "v" },
    keymaps.send_clipboard.key or prefix .. keymaps.send_clipboard.suffix,
    shortcut.build_func("clipboard"),
    { noremap = true, silent = true, desc = "send question2clipboard" }
  )
  vim.keymap.set(
    { "n", "v" },
    keymaps.send_chat.key or prefix .. keymaps.send_chat.suffix,
    shortcut.build_func("chat"),
    { noremap = true, silent = true, desc = "send question2ChatGPT" }
  )
  vim.keymap.set(
    { "n", "v" },
    keymaps.send_popup.key or prefix .. keymaps.send_popup.suffix,
    shortcut.build_func("popup"),
    { noremap = true, silent = true, desc = "send to get direct response" }
  )
  vim.keymap.set(
    { "n", "v" },
    keymaps.send_diff.key or prefix .. keymaps.send_diff.suffix,
    shortcut.build_func("diff"),
    { noremap = true, silent = true, desc = "send to get response with diff" }
  )
  -- utils
  vim.keymap.set(
    { "n", "v" },
    keymaps.resume_dialog.key or prefix .. keymaps.resume_dialog.suffix,
    target.resume_last_dialog,
    { noremap = true, silent = true, desc = "resume last dialog" }
  )
  vim.keymap.set(
    { "n", "v" },
    keymaps.load_file.key or prefix .. keymaps.load_file.suffix,
    tpl.repo_load_file,
    { noremap = true, silent = true, desc = "load current file to reg" }
  )
  vim.keymap.set(
    { "n", "v" },
    keymaps.append_file.key or prefix .. keymaps.append_file.suffix,
    tpl.repo_append_file,
    { noremap = true, silent = true, desc = "append current file to reg" }
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
