-- packer setup
vim.cmd([[packadd packer.nvim]])

require("packer").startup(function()
  use("wbthomason/packer.nvim")

  -- set mapleader and maplocalleader
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"

  -- plugins
  use({
    "you-n-g/simplegpt.nvim",
    config = function()
      require("simplegpt").setup()
    end,
    requires = {
      {
        "yetone/avante.nvim",
        event = "VimEnter",
        config = function()
          require("avante").setup({
            provider = "openai",
            openai = {
              endpoint = vim.env.OPENAI_BASE_URL,
              model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
              timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
              temperature = 0,
              max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
            },
          })
        end,
        requires = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
        },
      },
      "you-n-g/jinja-engine.nvim",
      "ibhagwan/fzf-lua",
    },
  })
end)
