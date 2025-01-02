# 🤏 SimpleGPT
[![Mega-Linter](https://github.com/you-n-g/simplegpt.nvim/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/mega-linter)
[![panvimdoc](https://github.com/you-n-g/simplegpt.nvim/actions/workflows/panvimdoc.yml/badge.svg)](https://github.com/kdheepak/panvimdoc)

🤏SimpleGPT is a Vim plugin designed to provide a simple yet flexible way to customize your LLM/ChatGPT prompts to for your tasks.

- Why 🤏SimpleGPT: **You need customized LLM/ChatGPT prompts for your tasks**.
  - AI Coding Plugins didn't provide support for every scenario.
    - General tasks beyond coding:
      - Article writing.
      - Reading, notetaking, summarizing.
      - Translating.
  - Even for specific tasks that AI Coding supports, using a customized prompt and workflow is often more effective and smooth.

## Design Philosophy

🤏SimpleGPT's efforts can be categorized into the following parts:
- **Prompt Templates**: Create your own prompt templates using a Jinja template engine. [Details](#custom-jinja-based-prompt-template)
- **Context-aware Question Building**: Construct questions based on the template and the current context, followed by multi-round chat instruction.
- **Flexible Response Presenting**: Present the response in the most convenient way (we provide options like diff, popup, replace, append).

This allows you to easily build a LLM-based toolbox with 🤏SimpleGPT.

We provide a tools gallery for basic usage, which also serves as examples for further customization.

| Tool             | Config | Demo |
| --               | --     | --   |
| Grammar fixing   |  [conf.lua](https://github.com/you-n-g/simplegpt.nvim/blob/4fa41a0f412c17bbd0588e7d3e9221399e682669/lua/simplegpt/conf.lua#L137)      |      |
| Text Rewriting   | [conf.lua](https://github.com/you-n-g/simplegpt.nvim/blob/4fa41a0f412c17bbd0588e7d3e9221399e682669/lua/simplegpt/conf.lua#L106)       |      |
| Code completing  | [conf.lua](https://github.com/you-n-g/simplegpt.nvim/blob/4fa41a0f412c17bbd0588e7d3e9221399e682669/lua/simplegpt/conf.lua#L126)       | [Demo](#code-completion--instruct-editing) |
| Code Explanation | [conf.lua](https://github.com/you-n-g/simplegpt.nvim/blob/4fa41a0f412c17bbd0588e7d3e9221399e682669/lua/simplegpt/conf.lua#L161)       | |
| Bug Fixing       | [conf.lua](https://github.com/you-n-g/simplegpt.nvim/blob/4fa41a0f412c17bbd0588e7d3e9221399e682669/lua/simplegpt/conf.lua#L168)       |      |
| Translation with great formatting      |  [conf.lua](https://github.com/you-n-g/simplegpt.nvim/blob/4fa41a0f412c17bbd0588e7d3e9221399e682669/lua/simplegpt/conf.lua#L182)      | [Demo](#translation-with-great-formatting) |
| Dictionary with customized explanation       |  [conf.lua](https://github.com/you-n-g/simplegpt.nvim/blob/4fa41a0f412c17bbd0588e7d3e9221399e682669/lua/simplegpt/conf.lua#L225)      | [Demo](#dictionary-with-customized-explanation) |
| Reading          | [My Config](https://github.com/you-n-g/deploy/blob/8535f451758e45b77b073bb65bb6e8e5baafa714/configs/lazynvim/lua/plugins/gpt.lua#L269)       |      |

More tools are coming soon.

# Installation
⚠️Please follow the [installation guide of ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim?tab=readme-ov-file#installation) to make sure your ChatGPT works.

You can use `:ChatGPT` to start a chat and verify if it is working.

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
    "you-n-g/jinja-engine.nvim",
    "ibhagwan/fzf-lua",
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
    "you-n-g/jinja-engine.nvim",
    "ibhagwan/fzf-lua",
  },
})
```

If you want to customize you `<LocalLeader>`, please use following code:
```lua
vim.g.maplocalleader = "\\"  -- change the localleader key to \
```

More detailed [configuration](lua/simplegpt/conf.lua) are listed here.
You can find my latest and preferred configuration [here](https://github.com/you-n-g/deploy/blob/master/configs/lazynvim/lua/plugins/gpt.lua) as an example.

# Demos

## Tools Gallery

### Code Completion & Instruct Editing
[![image](https://github.com/user-attachments/assets/f8d3b4e5-0e0b-42f1-a716-78a10e0fc3a7)](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fbrybs5bnheae1.gif)

### Translation with great formatting 
[![image](https://github.com/user-attachments/assets/b83bc78f-e125-4a39-9e38-6125eee41467)](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fjsusuibnheae1.gif)

### Dictionary with customized explanation
[![image](https://github.com/user-attachments/assets/9d52a367-76fe-4337-91d5-0eeb247c1c9e)](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2F1pigeebnheae1.gif)


## Typical workflow & Shortcuts
I have attempted to summarize the key concepts and manual in one image.

![image](https://github.com/user-attachments/assets/bf3db252-2679-4c45-a307-774754492134)

The question is constructed by rendering a template. The 't' register serves as the template, encompassing:
- Special variables such as `{{content}}`, `{{filetype}}`, and `{{visual}}`.
- Standard registers like `{{a}}`, `{{b}}`, and `{{c}}`.


# Features

## Custom Jinja-based Prompt Template

Here is a gif demo that quickly showcases the customization process.
[![image](https://github.com/user-attachments/assets/7469b4e3-6058-4a9c-b83f-6bd9536ba03e)](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fb1ne4nt6ubae1.gif)


### Setting a Custom Template Path
You can specify a custom template path for loading and dumping files by setting the `custom_template_path` option in your configuration. If the specified path does not exist, it will be created automatically.

Example configuration:
```lua
require("simplegpt").setup({
  custom_template_path = "~/my_custom_templates/"
})
```
When you set a custom_template_path:
- If a template is specified and it exists in the custom path, it will be loaded from and saved to that path.
- If the template file doesn't exist in the custom path, a new file will be created there when you save the registers.

### Steps to create a new template

#### Creating the template directly from file

1. **Create a Template File**: Navigate to your custom template path and create a `.json` file.

2. **Define Template Structure**: Add your template with placeholders:
   ```json
   {
     "t": "I am working on a {{filetype}} file. The content is: {{content}}. Selected lines: {{visual}}. Question: {{q}}."
   }
   ```

3. **Save**: Save the file in `custom_template_path`.

#### Creating the Template in Vim

1. **Set the 't' Register**: In Vim, set the 't' register:
   ```vim
   " setting it with command
   :let @t = "I am working on a {{filetype}} file. The content is: {{content}}. Selected lines: {{visual}}. Question: {{q}}."
   " or use `"ty` to copy the content to the 't' register
   ```

2. **Dump the Register**: Use the shortcut to dump the 't' register:
   ```vim
   :<LocalLeader>gD
   ```
### Registering Custom Shortcuts

You can register custom shortcuts to use templates from the custom template path. Here is an example of how to configure custom shortcuts:

```lua
require("simplegpt").setup({
  custom_template_path = "~/my_custom_templates/",
  keymaps = {
    custom_shortcuts = {
      ["<LocalLeader>sQ"] = {
        mode = { "n", "v" },
        tpl = "my_custom_template.json",
        target = "popup",
        opts = { noremap = true, silent = true, desc = "Use custom template" },
      },
    },
  },
})
```

In this example, pressing `<LocalLeader>sQ` in normal or visual mode will load the `my_custom_template.json` from the custom template path and send it to the popup target.

### Core workflow

The primary concepts that govern the functionality of this plugin are:

- Register-based, template-driven question construction: This approach allows for the dynamic creation of questions by leveraging the power of Vim registers. The registers serve as placeholders within the template, which are then replaced with the appropriate content during the question construction process.

- Dumping and loading of registers: This feature enables the preservation of register content across different sessions. It's important to note that temporary registers, denoted by `{{p-}}`, are exempt from this process and their content is not saved to disk.

- Response display targets: This refers to the destination where the response from ChatGPT is displayed. The plugin offers flexibility in choosing the target, allowing for a more tailored user experience.

### Registers

#### An Example of Template Rendering

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

#### vim-native registers

| Register | meaning                              |
| -        | -                                    |
| t        | The register for the template.       |
| others   | the variables to render the template |


#### Supported special registers
| key          | meaning                                                     |
| -            | -                                                           |
| content      | Partial file content around cursor (configurable length)    |
| full_content | The complete file content                                   |
| filetype     | The filetype of the current buffer                         |
| visual       | The selected lines in visual mode                          |
| context      | The nearby context of cursor (configurable lines up/down)  |
| all_buf      | Content of all loaded buffers with files on disk          |

#### Template Engine

SimpleGPT uses a Jinja-like template engine ([jinja-engine.nvim](https://github.com/you-n-g/jinja-engine.nvim)) to power its template system:

- **Variable Interpolation**: Access registers using `{{register_name}}` syntax
  ```json
  {
    "t": "I am working on a {{filetype}} file. The content is: {{content}}. Selected lines: {{visual}}. Question: {{q}}."
  }
  ```

- **Control Structures**: Use Jinja-style control flow
  ```jinja
  {% if visual %}Selected: {{visual}}{% else %}No selection{% endif %}
  ```

The template engine provides familiar Jinja-style syntax while being fully integrated with Neovim.

## Shortcuts
- Dialog shortcuts:
  - For all dialogs
    - `{"q", "<C-c>", "<esc>"}`: Exit the dialog
    - `{"<C-k>"}`: Extract code block closest to cursor
    - `{"<C-j>"}`: Cycle to next window
    - `{"<C-h>"}`: Cycle to previous window
    - `{"<C-s>"}`: Save registers (for template editing only)
    - `K`: Show special value for placeholder under cursor (for template editing only)
  - For `ChatDialog` (The dialog that can get responses)
    - `{"<C-a>"}`: Append response to original buffer after selection/current line
    - `{"<C-y>"}`: Copy full response to clipboard
    - `{"<C-r>"}`: Replace selected text/current line with response
    - `{"<m-c>"}`: Instruction Editing:
      - Continue conversation with current context
      - Opens input prompt for follow-up questions
      - New response replaces current response
- Normal shortcuts start with `<LocalLeader>g` (You can change it by setting `keymaps.prefix` when you setup the plugin)
  - Register operations:
    - `<LocalLeader>gl`: load registers
    - `<LocalLeader>gD`: dump registers
    - `<LocalLeader>ge`: edit registers
  - Send to target:
    - `<LocalLeader>gs`: send question to clipboard
    - `<LocalLeader>gc`: send question to ChatGPT
    - `<LocalLeader>gr`: send to get direct response
    - `<LocalLeader>gd`: send to get response with diff
  - Other operations:
    - `<LocalLeader>gR`: resume last popup
    - `<LocalLeader>gp`: load current file to reg
    - `<LocalLeader>gP`: append current file to reg
- Shortcuts for combined actions:  Loading template + send to target
  - By default, they start with `<LocalLeader>s` (You can change it by setting `keymaps.shortcuts.prefix` when you setup the plugin)
  - [Full list of shortcuts](lua/simplegpt/conf.lua#L25)
    - `<LocalLeader>sr`: (R)ewrite Text
    - `<LocalLeader>sc`: (C)omplete Code
    - `<LocalLeader>sg`: Fix (g)rammar
    - `<LocalLeader>sd`: Con(d)ense
    - `<LocalLeader>st`: Con(t)inue

An example to change the shortcuts prefix in lazy.nvim:
```lua
{
  "you-n-g/simplegpt.nvim",
  --- ... other configurations
  opts = {
    keymaps = {
      shortcuts = {
        prefix = "<m-g>",
      },
      prefix = "<m-g><m-g>",
    },
  },
  --- ... other configurations
}
```

# TODOs
Flag explanation:
- 🌟: high priority

- TODOs
  - Basic:
    - [x] Conversations
      - [x] Supporting multi-rounds conversation with context
      - [/] Converting current response to a new conversation template
        - Quick thought: we can build a ChatGPT session directly.
        - Chat Conversation is useful enough, so we cancel this feature.
    - [ ] Anonymous register to avoid confliction;
  - Misc
    - [ ] Inline selection & following operators
    - [x] Resume last answer.
    - [X] Diff mode
    - [x] Fast copy code in backquotes
    - [x] async Answering in the background(it will stop the answering streaming if we exit the QA UI)
      - It would boots the writing workflow.
        - We can create a new tab and ask the question further
    - [x] Temporary register(without saving to disk)
    - Repository level context
      - Add file content to context
        - [x] current file
      - [x] Ask repository-level question
    - Shortcuts
      - [ ] Telescope to run shortcuts.
      - [x] Directly ask error information (load + do!)
        - [x] while remain the original information.
    - Utils:
      - [ ] get the buffer number where you are from; It is helpful to accurate control the content in different windows.
  - Targets:
    - Run from targets;
      - Dialog targets ==>  Supporting edit in place.
      - [-] 🌟🐞 When we goto tex Diffpop for the second time. It will prompt to select the b:vimtex_main
          - Stop setting `b:vimtex_main` in my config solve this problem.
        - If you don't abort it. It will not appear again.
    - Followup actions;
      - [X] Replace the text
      - [X] Append the text
      - [X] Yank the text
      - [x] 🌟🐞The action line may is wrong when we enable new tab.
      - [x] 🌟🐞For visual selection, the append action will append content after the first line.
  - UI:
    - short cuts
    - [x] Help function: You can press `?` to see the help menu for shortcuts.
      - Alternative implementation: [ ] Add shortcuts prompt around the box
    - Add preview of the place holders inline
  - Navigation
    - [x] fast saving and loading(without entering name)
      - [x] remembering the filename in the background.
    - [x] Better Preview of the documents
  - Docs: try panvimdoc
    - [x] Normal vim doc(generating from README.md).
    - [x] One picture docs.
    - [X] Recording Demo
    - features demonstration:
      - repository-level QA building:
    - [ ] Document about the config
  - Open source routine
    - Vim CI
      - [X] Add linting CI
      - [ ] Fix Linting errors
        - [Switching to Mega-Linter](https://github.com/nvuillam/npm-groovy-lint/pull/109/files) may help.
        - Maybe Refining code by evolving framework.
    - [x] Automatic releasing (maybe tagging is included)
    - Tests:
      - Add test initialization configs for fast debugging and testing.
        - [X] lazy.nvim
        - [X] packer.nvim
  - templates design
    - [x] Ask inline questions(continue writing)
    - [x] Simplify the template design (merge templates)
    - [ ] Disable the back quotes in the template. Even though I add following content, it still does not work.
      ```
      ---- Example focused part ----
      def plus(a, b):
          # TODO: plus them and return
      ---- Example output part ----
      def plus(a, b):
          return a + b
      ```
  - Code Design:
    - [x] use `show` an `hide` to ctrl the conversation dialog

- Bugs
  - [x] Replace only affect one line(in the popup target).
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
