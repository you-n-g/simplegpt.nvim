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
⚠️Please follow the [installation guide of ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim?tab=readme-ov-file#installation) to make sure your ChatGPT works.
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

If you want to customize you `<LocalLeader>`, please use following code:
```lua
vim.g.maplocalleader = "\\"  -- change the localleader key to \
```

# Demo

## Typical workflow & Shortcuts
![Workflow](https://i.imgur.com/bPx6C1D.png)

The question is constructed by rendering a template. The 't' register serves as the template, encompassing:
- Special variables such as `{{content}}`, `{{filetype}}`, and `{{visual}}`.
- Standard registers like `{{a}}`, `{{b}}`, and `{{c}}`.

## Console demo
[![asciicast](https://asciinema.org/a/zACiIRbgl0F6duRR8aJgtWbqr.svg)](https://asciinema.org/a/zACiIRbgl0F6duRR8aJgtWbqr)
- Building a comprehensive question using the template mechanism.
- Adding ad hoc requirements based on the current context.
  - Implementing the code (default question) and translating the comments into Chinese (special requirements).
- The code that the demo is based on is [here](tests/demo/demo.py).


# Features

## Core workflow

The primary concepts that govern the functionality of this plugin are:

- Register-based, template-driven question construction: This approach allows for the dynamic creation of questions by leveraging the power of Vim registers. The registers serve as placeholders within the template, which are then replaced with the appropriate content during the question construction process.

- Dumping and loading of registers: This feature enables the preservation of register content across different sessions. It's important to note that temporary registers, denoted by `{{p-}}`, are exempt from this process and their content is not saved to disk.

- Response display targets: This refers to the destination where the response from ChatGPT is displayed. The plugin offers flexibility in choosing the target, allowing for a more tailored user experience.

## Registers

### An Example of Template Rendering

To illustrate the core template rendering mechanism of SimpleGPT, consider the following example. We have a template in the 't' register:

"I am currently working on a {{filetype}} file. The content of the file is: {{content}}. I have selected the following lines: {{visual}}. My question is: {{q}}."

The register values are:

- `{{filetype}}` is 'markdown'
- `{{content}}` is 'This is a sample markdown file.'
- `{{visual}}` is 'This is a selected.'
- `{{q}}` is 'How can I improve this line?'

The constructed question becomes:

"I am currently working on a markdown file. The content of the file is: This is a sample markdown file. I have selected the following lines: This is a selected line. My question is: How can I improve this line?"

Registers are of two types:

- Native vim registers: Standard Vim registers like 't', 'a', 'b', 'c', etc. used for storing and retrieving text.
- Special registers: Specific to SimpleGPT, including `{{content}}`, `{{filetype}}`, `{{visual}}`, and `{{q}}`. They store special values used in the template process. The `{{q}}` register allows for an editable question when rendering the whole content.

### vim-native registers

| Register | meaning                              |
| -        | -                                    |
| t        | The register for the template.       |
| others   | the variables to render the template |


### Supported special registers
| key             | meaning                                                     |
| -               | -                                                           |
| content         | the whole file content                                      |
| filetype        | the filetype of the file                                    |
| visual          | the selected lines                                          |
| context(TODO..) | the nearby context of the selected line(10 lines up & down) |



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
  - Register operations
    - `<LocalLeader>gl`: load registers
    - `<LocalLeader>gD`: dump registers
    - `<LocalLeader>ge`: edit registers
  - Send to target
    - `<LocalLeader>gs`: send question to clipboard
    - `<LocalLeader>gc`: send question to ChatGPT
    - `<LocalLeader>gr`: send to get direct response
    - `<LocalLeader>gd`: send to get response with diff
  - Other operations
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
    - [X] Recording Demo
    - features demonstration:
      - repository-level QA building:
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
    - [ ] Simplify the template design (merge templates)
    - [ ] Disable the back quotes in the template. Even though I add following content, it still does not work.
      ```
      ---- Example focused part ----
      def plus(a, b):
          # TODO: plus them and return
      ---- Example output part ----
      def plus(a, b):
          return a + b
      ```

- Bugs
  - [ ] Replace only affect one line(in the popup target).
  - [x] It raises errors when `<c-r>` in popup target.

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
