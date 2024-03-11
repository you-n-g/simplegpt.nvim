# 🤏 SimpleGPT
[![Mega-Linter](https://github.com/you-n-g/simplegpt.nvim/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/mega-linter)
[![panvimdoc](https://github.com/you-n-g/simplegpt.nvim/actions/workflows/panvimdoc.yml/badge.svg)](https://github.com/kdheepak/panvimdoc)

🤏SimpleGPT is a vim plugin designed to provide the simplest method for:
- Constructing and sending questions to ChatGPT
- Presenting the response in the most convenient manner.

## Motivation of this plugin
Though we have [a lot of ChatGPT plugins](#related-projects) to leverage the power of ChatGPT in Vim, I still find it hard to locate a handy one that completely fits my workflow.

After thinking about it, I found that the main reason is that the most important part of my workflow is missing in existing plugins: **Fast editing of questions based on my current status**!!

So, **quickly editing the question template and building the question** is the most important part of my workflow. Existing plugins are not convenient enough for this and focus more on the Chat UI.

This repository is designed to offer a highly customizable and extensible QA interaction with ChatGPT in the simplest way possible.

# Installation
⚠️ Please follow the [installation guide of ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim?tab=readme-ov-file#installation) to make sure your ChatGPT works.
```lua
-- Lazy.nvim
{
  "you-n-g/simplegpt.nvim",
  dependencies = {
    {
      "jackMort/ChatGPT.nvim", -- You should configure your ChatGPT make sure it works.
      event = "VeryLazy",
      config = true,
      dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "folke/trouble.nvim",
        "nvim-telescope/telescope.nvim",
      },
    },
  },
  config = true,
},

-- or packer.nvim
use({
  "you-n-g/simplegpt.nvim",
  config = function()
    require("simplegpt").setup()
  end,
  requires = {
    {
      "jackMort/ChatGPT.nvim", -- You should configure your ChatGPT make sure it works.
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
```

# Demo

## Typical workflow & Shortcuts
![Workflow](https://i.imgur.com/bPx6C1D.png)

The question is constructed by rendering a template. The 't' register serves as the template, encompassing:
- Special variables such as {{content}}, {{filetype}}, and {{visual}}.
- Standard registers like {{a}}, {{b}}, and {{c}}.

## Console demo
TODO...


# Features

## Shutcuts
- Dialog shortcuts:
  - For all dialogs
    - `{"q", "<C-c>", "<esc>"}`: exit the dialog;
    - `{"C-k"}` Copy code in triple backquotes of current buffer;
  - For only `ChatDialog` (The dialog that are able to get response)
    - `{"C-a"}`: Append the response to current meeting.
    - `{"C-y"}`: Copy the full response to the clipboard.
    - `{"C-r"}`: Replace the selected visual text or current line.

- Normal shortcuts start with `<LocalLeader>g`
    - `<LocalLeader>gl`: load registers
    - `<LocalLeader>gD`: dump registers
    - `<LocalLeader>ge`: edit registers
    - `<LocalLeader>gs`: send question to clipboard
    - `<LocalLeader>gc`: send question to ChatGPT
    - `<LocalLeader>gr`: send to get direct response
    - `<LocalLeader>gd`: send to get response with diff
    - `<LocalLeader>gR`: resume last popup
    - `<LocalLeader>gp`: load current file to reg
    - `<LocalLeader>gP`: append current file to reg
- Shortcuts for combined actions:  Loading template + send to target
  - By default, they start with `<LocalLeader>s`.
  - [Full list of shortcuts](lua/simplegpt/conf.lua#L25)
    - `<LocalLeader>sr`: (R)ewrite Text
    - `<LocalLeader>sc`: (C)omplete Code
    - `<LocalLeader>sg`: Fix (g)rammar
    - `<LocalLeader>sd`: Con(d)ense
    - `<LocalLeader>st`: Con(t)inue

## Supported special registers
| key             | meaning                                                     |
| -               | -                                                           |
| content         | the whole file content                                      |
| filetype        | the filetype of the file                                    |
| visual          | the selected lines                                          |
| context(TODO..) | the nearby context of the selected line(10 lines up & down) |


# TODOs
Flag explanation:
- 🌟: high priority

- TODOs
  - Misc
    - [x] Resume last answer.
    - [X] Diff mode
    - [x] Fast copy code in backquotes
    - [ ] Answering in the background(it will stop the answering streaming if we exit the QA UI)
    - [x] Temporary register(without saving to disk)
    - Repository level context
      - Add file content to context
        - [x] current file
      - [x] Ask repository-level question
    - Shortcuts
      - [ ] Telescope to run shortcuts.
      - [ ] Directly ask error information (load + do!)
        - [ ] while remain the original information.
    - Utils:
      - [ ] get the buffer number where you are from; It is helpful to accurate control the content in different windows.
  - Targets:
    - Run from targets;
      - Dialog targets ==>  Supporting edit in place.
    - Followup actions;
      - [X] Replace the text
      - [X] Append the text
      - [X] Yank the text
  - UI:
    - short cuts
    - [ ] Help function: You can press `?` to see the help menu for shortcuts.
      - Alternative implementation: [ ] Add shortcuts prompt around the box
    - Add preview of the place holders inline
  - Navigation
    - [x] fast saving and loading(without entering name)
      - [x] remembering the filename in the background.
    - [x] Better Preview of the documents
  - Docs: try panvimdoc
    - [x] 🌟Normal vim doc(generating from README.md).
    - [x] 🌟One picture docs.
    - [ ] Recording Demo
  - Open source routine
    - Vim CI
      - [X] Add linting CI
      - [ ] Fix Linting errors
        - [Switching to Mega-Linter](https://github.com/nvuillam/npm-groovy-lint/pull/109/files) may help.
    - [ ] Automatic releasing (maybe tagging is included)
    - Tests:
      - Add test initialization configs for fast debugging and testing.
        - [X] lazy.nvim
        - [X] 🌟packer.nvim
  - templates design
    - [x] Ask inline questions(continue writing)

- Bugs
  - [ ] Replace only affect one line.

- More features that may be added in the long future
  - Automatically ask questions based on the current context(Currently we have to manually select and ask the question)

# Development

Welcome to contribute to this project.

You can test the plugin with minimal config with
- `vim -u tests/init_configs/lazy.lua -U NONE -N -i NONE` for [lazy.nvim](https://github.com/folke/lazy.nvim)
- For [packer.nvim](https://github.com/wbthomason/packer.nvim)
  - Please install [packer.nvim](https://github.com/wbthomason/packer.nvim) first.
  - Run `vim -u tests/init_configs/packer.lua  -U NONE -N -i NONE`

# Limitations

- It only leverage the `ChatCompletion` API (which is the most powerful and frequently used in the future trend).
- It is based on Vim registers, which may conflict with users' usage of them.

# Related Projects
- [jackMort/ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim)
- [robitx/gp.nvim](https://github.com/Robitx/gp.nvim)
