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
    "<LocalLeader>gl",
    loader.tele_load_reg,
    { noremap = true, silent = true, desc = "load registers" }
  )
  vim.keymap.set(
    "n",
    "<LocalLeader>gD",
    loader.input_dump_name,
    { noremap = true, silent = true, desc = "dump registers" }
  )
  vim.keymap.set({ "n", "v" }, "<LocalLeader>ge", function()
    local rqa = tpl.RegQAUI()
    rqa:build()
  end, { noremap = true, silent = true, desc = "edit registers" })
  vim.keymap.set(
    { "n", "v" },
    "<LocalLeader>gs",
    shortcut.build_func("clipboard"),
    { noremap = true, silent = true, desc = "send question2clipboard" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<LocalLeader>gc",
    shortcut.build_func("chat"),
    { noremap = true, silent = true, desc = "send question2ChatGPT" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<LocalLeader>gr",
    shortcut.build_func("popup"),
    { noremap = true, silent = true, desc = "send to get direct response" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<LocalLeader>gd",
    shortcut.build_func("diff"),
    { noremap = true, silent = true, desc = "send to get response with diff" }
  )
  vim.keymap.set(
    { "n", "v" },
    "<LocalLeader>gR",
    target.resume_popup,
    { noremap = true, silent = true, desc = "resume last popup" }
  )
  vim.keymap.set("n", "<LocalLeader>gf", loader.tele_load_reg, { noremap = true, desc = "load tpl via telescope" })
end

function M.setup()
  M.setup_main_mappings()
  shortcut.register_shortcuts()
  require("which-key").register({
    ["<LocalLeader>s"] = { name = "+Shortcuts" },
    ["<LocalLeader>g"] = { name = "+SimpleGPT" },
  })
end

return M
