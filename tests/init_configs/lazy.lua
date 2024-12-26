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

-- ChatGPT.nvim has a different naming convention for the environment variable
if vim.env.OPENAI_BASE_URL then
  vim.env.OPENAI_API_HOST = vim.env.OPENAI_BASE_URL
end

local plugins = {
  {
    "you-n-g/simplegpt.nvim",
    dependencies = {
      -- "jackMort/ChatGPT.nvim", -- You should configure your ChatGPT make sure it works.
      {
        "jackMort/ChatGPT.nvim",
        event = "VeryLazy",
        config = true,
        dependencies = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
          "folke/trouble.nvim",
          "nvim-telescope/telescope.nvim",
        },
      },
      "you-n-g/jinja-engine.nvim",
      "ibhagwan/fzf-lua",
    },
    config = true,
  },
}

require("lazy").setup(plugins)
