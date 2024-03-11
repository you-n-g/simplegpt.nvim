-- packer setup
vim.cmd([[packadd packer.nvim]])

require("packer").startup(function()
  use("wbthomason/packer.nvim")

  -- set mapleader and maplocalleader
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"

  -- plugins
  use({
    "~/deploy/tools.py/simplegpt.nvim/",
    config = function()
      require("simplegpt").setup()
    end,
    requires = {
      {
        "jackMort/ChatGPT.nvim",
        event = "VimEnter",
        config = function()
          require("chatgpt").setup()
        end,
        requires = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
          "folke/trouble.nvim",
          "nvim-telescope/telescope.nvim",
        },
      },
    },
  })
end)
