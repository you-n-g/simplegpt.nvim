-- Installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- setup and init
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "\\" -- Same for `maplocalleader`

local plugins = {
  {
    "you-n-g/simplegpt.nvim",
    dependencies = {
      {
        "yetone/avante.nvim",
        event = "VeryLazy",
        opts = {
          provider = "openai",
          openai = {
            endpoint = vim.env.OPENAI_BASE_URL,
            model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
            timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
            temperature = 0,
            max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
          },
        },
        dependencies = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
        },
      },
      "you-n-g/jinja-engine.nvim",
      "ibhagwan/fzf-lua",
    },
    config = true,
  },
}

require("lazy").setup(plugins)
