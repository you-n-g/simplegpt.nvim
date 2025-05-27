# 🤏 SimpleGPT
[![Mega-Linter](https://github.com/you-n-g/simplegpt.nvim/actions/workflows/linter.yml/badge.svg)](https://github.com/marketplace/actions/mega-linter)
[![panvimdoc](https://github.com/you-n-g/simplegpt.nvim/actions/workflows/panvimdoc.yml/badge.svg)](https://github.com/kdheepak/panvimdoc)

🤏SimpleGPT is a Vim plugin designed to provide a simple (high transparency based on Jinja) yet flexible way (context-aware based on buffer, visual selection, LSP info, terminal etc.) to customize your LLM/ChatGPT prompts for your tasks (building chat or finishing tasks by replacing them with diff comparison, appending, SEARCH/REPLACE etc.) or building chat on nearly all kinds of LLM APIs.

## Why 🤏SimpleGPT:

### **You need customized LLM/ChatGPT prompts for your tasks**.

- AI Coding Plugins didn't provide support for every scenario.
  - General tasks beyond coding:
    - Article writing.
    - Reading, notetaking, summarizing.
    - Translating.
- Even for specific tasks that AI Coding supports, using a customized prompt and workflow is often more effective and smooth.


### You just need a simple way to chat with all kinds LLM

For a long time, I've been looking for a simple way to chat in VIM with any LLM—just having a conversation, without pulling in my codebase as context (VIM is a tool far beyond code).
- 🍰 Why a simple way? Many LLM-chatting plugins come with lots of features—session management, code extraction, shortcuts to scroll content, and more. But as an experienced Vim user, I already have many of these features through my plugins. If I can just chat in a buffer, I have everything I need. Extra shortcuts that don't fit my setup only add unnecessary complexity.
- 🦾 Can't existing chat plugins support all kinds of LLMs? While pure Vim-powered chat plugins like [jackMort/ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim) and [robitx/gp.nvim](https://github.com/Robitx/gp.nvim) are excellent, they do not support reasoning models.

SimpleGPT aims to solve this problem.
- 🍰 It only provides the core feature to chat in an existing buffer. The chat will be organized by emoji like 👤(user), 🤖(AI), 💻(system).  
   and only one customizable shortcut, which is `<LocalLeader>gc` (to trigger chat completion or stop the chat completion stream). You can edit your conversation like a normal buffer and continue chat completion freely.
- 🦾 It supports all kinds of LLMs, including reasoning models. It's backend is based on [yetone/avante.nvim](https://github.com/yetone/avante.nvim), which supports a wide range of LLMs.

What's more🎁!
- Simple here means we removed features that Vim users don't need.
- We also include a Jinja engine to help you use context in your chats more quickly. This is the key for efficient chatting. You can create your own templates over time to chat even more efficiently.

Here is a Jinja template example (this shows how you can build rich, context-aware chat experiences):
`````jinja
You are an expert in programming.

{% if p %}
Here are a list of files for reference.
{{p-}}
{% endif %}

We have a file named {{filename}} with content:
````{{filetype}} 
{{content}}
````

{%if terminal%}
You encountered error when running or compiling it
```
{{terminal}}
```
{% endif %}


{% if visual %}The error are potentially caused by the following code block(We call it *focused code block*).
```{{filetype}} 
{{visual}}
```
Please only return the code to replace the *focused code block*{% else %}
{{f-}}
{% endif %}

{{q}}
`````


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
| Terminal with LLM supported | [Config](https://github.com/you-n-g/simplegpt.nvim/blob/b14c715fda43a0b34cc18ba4394e3440c883f3d5/lua/simplegpt/conf.lua#L279)| [Demo](#terminal-with-llm-supported) |
| Code editing with LSP information | [Config](https://github.com/you-n-g/simplegpt.nvim/blob/b14c715fda43a0b34cc18ba4394e3440c883f3d5/lua/simplegpt/conf.lua#L157) | [Demo](#code-editing-with-lsp-information) |
| Code editing with terminal context | [Config](https://github.com/you-n-g/simplegpt.nvim/blob/b14c715fda43a0b34cc18ba4394e3440c883f3d5/lua/simplegpt/conf.lua#L211) | [Demo](#code-editing-with-terminal-context) |

Chat
- Start a buffer and chat: [Demo](#chat-in-a-buffer)
- Build Chat based on Rich Context: [Demo](#build-chat-based-on-rich-context)

More tools are coming soon.

# Installation
Our project aims to make customizing your LLM/ChatGPT prompts straightforward by using the [yetone/avante.nvim](https://github.com/yetone/avante.nvim) as the backend API, ensuring we don't reinvent the wheel while supporting diverse models.


⚠️Please follow the [installation guide of avante.nvim](https://github.com/yetone/avante.nvim#installation) to make sure it works.

You can use `:AvanteAsk` to start a chat and verify if it is working.

```lua
-- Lazy.nvim
{
  "you-n-g/simplegpt.nvim",
  dependencies = {
    {
      "yetone/avante.nvim", -- You should configure your avante.nvim make sure it works.
      event = "VeryLazy",
      opts = {<your config>},
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

-- or packer.nvim
use({
  "you-n-g/simplegpt.nvim",
  config = function()
    require("simplegpt").setup()
  end,
  requires = {
    {
      "yetone/avante.nvim", -- You should configure your avante.nvim make sure it works.
      event = "VimEnter",
      config = function()
        require("avante").setup({<your config>})
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
```

If you want to customize you `<LocalLeader>`, please use following code:
```lua
vim.g.maplocalleader = "\\"  -- change the localleader key to \
```

More detailed [configuration](lua/simplegpt/conf.lua) are listed here.
You can find my latest and preferred configuration [here](https://github.com/you-n-g/deploy/blob/master/configs/lazynvim/lua/plugins/ai.lua) as an example.

# Demos

## Tools Gallery

### Code Completion & Instruct Editing
[![image](https://github.com/user-attachments/assets/f8d3b4e5-0e0b-42f1-a716-78a10e0fc3a7)](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fbrybs5bnheae1.gif)

### Translation with great formatting 
[![image](https://github.com/user-attachments/assets/b83bc78f-e125-4a39-9e38-6125eee41467)](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fjsusuibnheae1.gif)

### Dictionary with customized explanation
[![image](https://github.com/user-attachments/assets/9d52a367-76fe-4337-91d5-0eeb247c1c9e)](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2F1pigeebnheae1.gif)


### Terminal with LLM supported
[![image](https://github.com/user-attachments/assets/cc216866-e821-4b95-a6cd-eb973dc5f54d)](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fz7x2ku0a8lye1.gif)

- Press `<localleader>st` in a terminal buffer to open the LLM dialog.
- Enter your request or command.
- Edit the suggestion to keep only what you want.
- Press `<c-a>` to add the chosen command to the terminal.

### Code editing with LSP information
[![image](https://github.com/user-attachments/assets/6105781e-386e-4caf-8815-ea97018d1ef7)](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2F8iwol1a98lye1.gif)

- Select the code you want to fix.  
- Press `<localleader>sl` to use the code editing feature and address LSP warnings or errors.  
- Press `<c-r>` to replace the selected text with the suggested fix.

### Code editing with terminal context
[![image](https://github.com/user-attachments/assets/9f82e709-2f1c-439b-8cb2-6314d62624e2)](https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fn2n26dqa8lye1.gif)

- Run `ls` and `python <your script>` to gather live feedback from the terminal.
- Press `<localleader>sF` to use the code editing feature and fix errors detected in the terminal output.
- Press `<m-r>` to apply search and replace actions to quickly update your code based on the suggestions.

## Typical workflow & Shortcuts
I have attempted to summarize the key concepts and manual in one image.

![image](https://github.com/user-attachments/assets/bf3db252-2679-4c45-a307-774754492134)

The question is constructed by rendering a template. The 't' register serves as the template, encompassing:
- Special variables such as `{{content}}`, `{{filetype}}`, and `{{visual}}`.
- Standard registers like `{{a}}`, `{{b}}`, and `{{c}}`.

## Chat

### Chat In A Buffer
[![image](https://github.com/user-attachments/assets/9ada0d88-66e0-4236-a69b-665160e4bcb9)](https://i.redd.it/jqfhzckd2d2f1.gif)

- Press `<localleader>gc` to send current buffer as question to chat or continue chat.
- Press `<localleader>gc` to stop the chat stream.

### Build Chat based on Rich Context
[![image](https://github.com/user-attachments/assets/737d4cbe-9ab0-4e9d-892f-5d7a57887592)](https://i.redd.it/vvvz21cv3d2f1.gif)


- Call any tools (e.g. `<localleader>se`) to build according question based on context.
- Press `Q` to convert the question into a new chat.
- Press `<localleader>gc` to continue chat.

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
You can use these variables in your jinja template.
| key          | meaning                                                     |
| -            | -                                                           |
| content      | Content around the cursor, limited by a configurable length |
| full_content | Entire content of the current file                          |
| filetype     | Filetype of the current buffer                              |
| visual       | Lines selected in visual mode                               |
| context      | Context around the cursor, configurable lines up/down       |
| all_buf      | Content from all loaded buffers with files on disk          |
| lsp_diag     | LSP diagnostics information for the selected lines          |
| md_context   | Directly loading the content in `.sgpt.md` as the register value. |
| filename     | The name of the current file                                |
| terminal     | The content from the active (visiable) terminal buffer, capturing recent terminal output (if available) |
| full_terminal     | like terminal, but including all terminal output |
| p            | If register `p` contains a list of file paths (one per line), its value becomes the concatenation of the content from each of those files. Files that do not exist will be skipped. |

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

## Post-response Actions

After receiving a response from ChatGPT, you can perform several actions to integrate the output into your workflow:

- **Append**: Use the Append action (e.g., `<C-a>` key) to add the response to your original buffer.
- **Replace**: Use the Replace action (e.g., `<C-r>` key) to substitute the selected text, current line, or entire file with the response.
- **Yank**: Use the Yank action (e.g., `<C-y>` key) to copy the response to the clipboard.
- **Search and Replace**: Use the Search and Replace action (e.g., `<m-r>` key) to apply automated modifications via SEARCH/REPLACE blocks.
- **Chat/Continue**: Use the Chat action (e.g., `<m-c>` key) to continue the conversation or refine the response.


## Shortcuts
- Dialog shortcuts:
  - For all dialogs
    - `{"q", "<C-c>", "<esc>"}`: Exit the dialog
    - `{"<C-k>"}`: Extract code block closest to cursor
    - `{"<C-j>"}`: Cycle to next window
    - `{"<C-h>"}`: Cycle to previous window
    - `{"<C-s>"}`: Save registers (for template editing only)
    - `K`: Show special value for placeholder under cursor (for template editing only)
    - `Q`: Send current question or conversation to a buffer for chatting.
  - For `ChatDialog` (The dialog that can get responses)
    - `{"<C-a>"}`: Append response to original buffer after selection/current line
    - `{"<C-y>"}`: Copy full response to clipboard
    - `{"<C-r>"}`: Replace selected text/current line with response
    - `{"<m-c>"}`: Instruction Editing:
      - Continue conversation with current context
      - Opens input prompt for follow-up questions
      - New response replaces current response
    - `{"<m-r>"}`: Apply search and replace blocks to modify code based on the response
    - `[]`: Navigate(prev/next) between responses/answers
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
    - `<LocalLeader>gR`: toggle the dialog.
    - `<LocalLeader>gp`: load current file to reg
    - `<LocalLeader>gP`: append current file to reg
  - Buffer Chatting:
    - `<LocalLeader>c`: Start chatting in current buffer.
- Shortcuts for combined actions:  Loading template + send to target
  - By default, they start with `<LocalLeader>s` (You can change it by setting `keymaps.shortcuts.prefix` when you setup the plugin)
  - [Full list of shortcuts](lua/simplegpt/conf.lua#L25)
    - `<LocalLeader>sr`: (R)ewrite Text in Diff Mode.
    - `<LocalLeader>sC`: (C)omplete Code in Popup (with explanations).
    - `<LocalLeader>sc`: (C)omplete Code in Diff Mode (no explanation).
    - `<LocalLeader>sl`: Fix code using LSP diagnostics.
    - `<LocalLeader>sg`: (G)rammar Fix.
    - `<LocalLeader>sd`: (D)ense for condensing text.
    - `<LocalLeader>st`: (T)hread or Continue conversation.
    - `<LocalLeader>se`: (E)xplain Code or Text.
    - `<LocalLeader>sF`: (F)ix code with error messages.
    - `<LocalLeader>sE`: (E)xplain Text with Translation.
    - `<LocalLeader>sT`: (T)ranslate text.
    - `<LocalLeader>sq`: (Q)uestion with content.
    - `<LocalLeader>sf`: Edit Entire (F)ile in Diff Mode.
    - `<LocalLeader>s<m-f>`: Send current file for file edit via search/replace blocks.
    - `<LocalLeader>sD`: (D)ictionary lookup.

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
- [yetone/avante.nvim](https://github.com/yetone/avante.nvim)
