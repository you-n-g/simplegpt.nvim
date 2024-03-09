# 🤏 SimpleGPT
Simple GPT is a simple, **QA-customizable** plugin for interacting with ChatGPT in Vim.

# Motivation of this plugin
Though we have [a lot of ChatGPT plugins](#related-projects) to leverage the power of ChatGPT in Vim, I still find it hard to locate a handy one that completely fits my workflow.

After thinking about it, I found that the main reason is that the most important part of my workflow is missing in existing plugins: **Fast editing of questions based on my current status**!!

So, quickly editing the question template and building the question is the most important part of my workflow. Existing plugins are not convenient enough for this and focus more on the Chat UI.

This repository is designed to offer a highly customizable and extensible QA interaction with ChatGPT in the simplest way possible.



# TLDR(Too Long Didn't Read)


# Installation
```lua
-- TODO: update the content according to `tests/init_configs/lazy.lua`
-- Layzynvim
{
  "you-n-g/simplegpt.git",
  -- "folke/which-key.nvim", is recommended for better experience
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "jackMort/ChatGPT.nvim",  -- You should configure your ChatGPT make sure it works.
  },
  config=true,
}
```

# Features


Supported special registers
| key             | meaning                                                     |
| -               | -                                                           |
| content         | the whole file content                                      |
| filetype        | the filetype of the file                                    |
| visual          | the selected lines                                          |
| context[TODO..] | the nearby context of the selected line(10 lines up & down) |


# Shutcuts
- Dialog shortcuts:
  - For all dialogs
    - `{"q", "<C-c>", "<esc>"}`: exit the dialog;
    - `{"C-k"}` Copy code in triple backquotes of current buffer;
  - For only `ChatDialog` (The dialog that are able to get response)
    - `{"C-a"}`: Append the response to current meeting.
    - `{"C-y"}`: Copy the full response to the clipboard.
    - `{"C-r"}`: Replace the selected visual text or current line.

- normal shortcuts:
  - ...

# TODOs

- TODOs
  - Misc
    - [x] Resume last answer.
    - [X] Diff mode
    - [x] Fast copy code in backquotes
    - [ ] Answering in the background
    - [x] Temporary register(without saving to disk)
    - Repository level context
      - Add file content to context
        - [ ] current file
      - [ ] Ask repository-level question
    - Shotcuts
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
  - Navigation
    - [ ] fast saving and loading(without entering name)
      - [ ] remembering the filename in the background.
    - [x] Better Preview of the documents
  - Docs: try panvimdoc
    - [ ] Normal vim doc(generating from README.md).
    - [ ] One picture docs.
  - Open source routine
    - Vim CI
      - [X] Add linting CI
      - [ ] Fix Linting errors
    - Tests:
      - Add test initialization configs for fast debugging and testing.
        - [X] lazy.nvim
  - templates design
    - [x] Ask inline questions(continue writing)

- Bugs
  - [ ] qq will trigger error in answer


# Development

Welcome to contribute to this project.

You can test the plugin with minimal config with
- `vim -u tests/init_configs/lazy.lua -U NONE -N -i NONE` for [lazy.nvim](https://github.com/folke/lazy.nvim)

# Limitations

- It only leverage the `ChatCompletion` API (which is the most powerful and frequently used in the future trend).
- It is based on Vim registers, which may conflict with users' usage of them.

# Related Projects
- [jackMort/ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim)
- [robitx/gp.nvim](https://github.com/Robitx/gp.nvim)
