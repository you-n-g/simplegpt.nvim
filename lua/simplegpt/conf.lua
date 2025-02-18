-- (intention design principle) we try to handle
-- - the output format and context building (main structure) in the conf file (because it is less variable)
-- - the intention in the varibables/registers
local intentions = {
  refine = "Please refine the code. Make it more consistent (e.g., consistency among the code, document, annotation, variable naming), readable (e.g., fix typos), and standard (e.g., follow the coding linting).",
}

-- describe the designed format
local format = {
  code_only = "No extra explanations.\nNo block quotes. DO NOT include three backticks ``` in the code. Try to keep all the comments (You can modify them to make it better).\nKeep original indent so that we can replace the original code with the newly generated one.",
  diff= [=[
    Please suggest modification to meet the requirements. Please follow the *SEARCH/REPLACE block* Rules!!!! It is optional.
    Please make it concise and less than 20 lines!!!

    # *SEARCH/REPLACE block* Rules:

    Every *SEARCH/REPLACE block* must use this format:
    1. The *FULL* file path alone on a line, verbatim. No bold asterisks, no quotes around it, no escaping of characters, etc.
    2. The opening fence and code language, eg: ```python
    3. The start of search block: <<<<<<< SEARCH
    4. A contiguous chunk of lines to search for in the existing source code
    5. The dividing line: =======
    6. The lines to replace into the source code
    7. The end of the replace block: >>>>>>> REPLACE
    8. The closing fence: ```

    Use the *FULL* file path, as shown to you by the user.

    Every *SEARCH* section must *EXACTLY MATCH* the existing file content, character for character, including all comments, docstrings, etc.
    If the file contains code or other data wrapped/escaped in json/xml/quotes or other containers, you need to propose edits to the literal contents of the file, including the container markup.

    *SEARCH/REPLACE* blocks will *only* replace the first match occurrence.
    Including multiple unique *SEARCH/REPLACE* blocks if needed.
    Include enough lines in each SEARCH section to uniquely match each set of lines that need to change.

    Keep *SEARCH/REPLACE* blocks concise.
    Break large *SEARCH/REPLACE* blocks into a series of smaller blocks that each change a small portion of the file.
    Include just the changing lines, and a few surrounding lines if needed for uniqueness.
    Do not include long runs of unchanging lines in *SEARCH/REPLACE* blocks.

    Only create *SEARCH/REPLACE* blocks for files that the user has added to the chat!

    To move code within a file, use 2 *SEARCH/REPLACE* blocks: 1 to delete it from its current location, 1 to insert it in the new location.

    Pay attention to which filenames the user wants you to edit, especially if they are asking you to create a new file.

    If you want to put code in a new file, use a *SEARCH/REPLACE block* with:
    - A new file path, including dir name if needed
    - An empty `SEARCH` section
    - The new file's contents in the `REPLACE` section

    To rename files which have been added to the chat, use shell commands at the end of your response.

    If the user just says something like "ok" or "go ahead" or "do that" they probably want you to make SEARCH/REPLACE blocks for the code changes you just proposed.
    The user will say when they've applied your edits. If they haven't explicitly confirmed the edits have been applied, they probably want proper SEARCH/REPLACE blocks.

    You are diligent and tireless!
    You NEVER leave comments describing code without implementing it!
    You always COMPLETELY IMPLEMENT the needed code!


    ONLY EVER RETURN CODE IN A *SEARCH/REPLACE BLOCK*!
    Examples of when to suggest shell commands:

    - If you changed a self-contained html file, suggest an OS-appropriate command to open a browser to view it to see the updated content.
    - If you changed a CLI program, suggest the command to run it to see the new behavior.
    - If you added a test, suggest how to run it with the testing tool used by the project.
    - Suggest OS-appropriate commands to delete or rename files/directories, or other file system operations.
    - If your code changes add new dependencies, suggest the command to install them.
    - Etc.

    Here is a example of SEARCH/REPLACE BLOCK to change a function implementation to import.

    <<<<<<< SEARCH
    def hello():
        "print a greeting"

        print("hello")
    =======
    from hello import hello

    >>>>>>> REPLACE
]=]
}

-- what shortcuts are available in the dialog
local BASE_DIALOG_KEYMAPS = {
  "exit_keys",
  "cycle_next",
  "cycle_prev",
  "yank_code",
  "extract_code",
}
local TPL_DIALOG_KEYMAPS = {
  "show_value",
  -- "", restore to default value
}
local LOCAL_QA_DIALOG_KEYMAPS = {
  "append_keys",
  "replace_keys",
  "yank_keys",
  "chat_keys",
}

local M = {
  options = {},
  defaults = {
    -- TODO: remove the new tab feature if it is not necessary
    -- should we open new tab for QA (for supporting async QA);
    -- We have hidding feature now. So we don't need QA now.
    new_tab = false,
    ui = {
      layout = {
        size = {
          width = "95%",
          height = "95%",
        },
      },
      name_map = { -- map the name of features to a more readable name
        exit_keys = "exit&continue",
        append_keys = "append",
        replace_keys = "replace",
        yank_keys = "yank",
        chat_keys = "chat",
      },
    },
    dialog = {
      -- Dialog keymaps
      keymaps = {
        show_value = { "K" }, -- Default key for showing special value
        -- Base Dialog shortcuts
        exit_keys = { "q", "<c-c>", "<esc>" },
        cycle_next = { "<tab>" },
        cycle_prev = { "<S-Tab>" },
        yank_code = { "<C-c>" },
        extract_code = { "<C-k>" },

        -- QA Dialog shortcuts
        -- - append the response to original buffer
        append_keys = {
          "<C-a>",
        },
        -- - replace the target(selected buffer, current line or entire file) with the response
        replace_keys = {
          "<C-r>",
        },
        -- - yank the response to clipboard
        yank_keys = {
          "<C-y>",
        },
        -- - chat with current context
        chat_keys = { "<m-c>" },
      },
    },
    -- custom data path for loading and dumping files
    custom_template_path = nil,

    q_build = {
      -- repository-level configs
      repo = {
        reg = "p", -- the register to inject re(p)ository-level infos
        header = "Below are some relavant files", -- the header for multiple files
      },
    },

    keymaps = { -- these are keymap that does not belong to a specific conponent like dialog.
      -- shortcuts to actions: directly loading specific template and sent to target(they are often concrete applications)
      -- Default shortcuts
      shortcuts = {
        -- prefix = "<m-g>", -- I think this would be more convenient.
        prefix = "<LocalLeader>s",
        list = { -- prefix is not here
          -- Rewritting does not need giving extra explanations. So we directly send it to diff.
          -- {
          --   mode = { "n", "v" },
          --   suffix = "r",
          --   tpl = "complete_writing_replace.json",
          --   target = "popup",
          --   opts = { noremap = true, silent = true, desc = "(R)ewrite Text" },
          -- },
          {
            mode = { "n", "v" },
            suffix = "r",
            tpl = "complete_writing_replace.json",
            target = "diff",
            reg = {
              r = "No extra explanations. No block quotes. Output only the rewritten text. Maintain prefix spaces and indentations.",
            },
            opts = { noremap = true, silent = true, desc = "(R)ewrite Text in Diff" },
          },
          {
            mode = { "n", "v" },
            suffix = "C",
            tpl = "code_complete.json",
            target = "popup",
            reg = {
              q = "Please fix all the errors and complete all the missing feature in the focused part.\nYou don't have to output the complete code. You can output the key part with some extra context.",
            },
            opts = { noremap = true, silent = true, desc = "(C)omplete Code" },
          },
          {
            mode = { "n", "v" },
            suffix = "c",
            tpl = "code_complete.json",
            target = "diff",
            reg = {
              q = "Please fix all the errors and complete all the missing feature in the focused part.\n"
                .. format.code_only,
            },
            opts = { noremap = true, silent = true, desc = "(C)omplete Code no explain" },
          },
          {
            mode = { "v" },
            suffix = "l",
            tpl = "code_complete_w_lsp.json",
            target = "diff",
            reg = {
              q = "Please fix all the errors reported by the LSP diagnostics information.\n"
                .. format.code_only,
            },
            opts = { noremap = true, silent = true, desc = "Fix diagnostics information." },
          },
          {
            mode = { "n", "v" },
            suffix = "g",
            tpl = "fix_grammar.json",
            target = "diff",
            reg = {
              r = "No extra explanations. No block quotes. Output only the rewritten text. Maintain prefix spaces and indentations.",
            },
            opts = { noremap = true, silent = true, desc = "Fix (g)rammar" },
          },
          {
            mode = { "n", "v" },
            suffix = "d",
            tpl = "condensing.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "Con(d)ense" },
          },
          {
            mode = { "n", "v" },
            suffix = "t",
            tpl = "continue.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "Con(t)inue" },
          },
          {
            mode = { "n", "v" },
            suffix = "e",
            tpl = "code_explain.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "(E)xplain or Question" },
          },
          {
            mode = { "n", "v" },
            suffix = "F",
            tpl = "fix_bug_with_err.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "(F)ix errors" },
          },
          {
            mode = { "n", "v" },
            suffix = "E",
            tpl = "explain_text.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "(E)xplain Text with Trans" },
          },
          {
            mode = { "n", "v" },
            suffix = "T",
            tpl = "translate.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "(T)ranslate" },
          },
          {
            mode = { "n", "v" },
            suffix = "q",
            tpl = "question.json",
            target = "chat",
            opts = { noremap = true, silent = true, desc = "Ask (q)uestion with content" },
          },
          {
            mode = { "n", "v" },
            suffix = "f",
            tpl = "file_edit.json",
            target = "diff",
            opts = { noremap = true, silent = true, desc = "Edit Entire (F)ile" },
            context = { replace_target = "file" },
          },
          {
            mode = { "n", "v" },
            suffix = "<m-f>",
            tpl = "file_edit.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "Edit Entire (F)ile with diff" },
            -- context = { replace_target = "file" },
            reg = {
              q = format.diff
            },
          },
          {
            mode = { "n" },
            suffix = "<m-r>",
            tpl = "file_edit.json",
            target = "diff",
            opts = { noremap = true, silent = true, desc = "(R)efine Entire File" },
            context = { replace_target = "file" },
            reg = {
              q = intentions.refine,
            },
          },
          {
            mode = { "v" },
            suffix = "<m-r>",
            tpl = "code_complete.json",
            target = "diff",
            opts = { noremap = true, silent = true, desc = "(R)efine selection" },
            reg = {
              q = intentions.refine .. "\n" .. format.code_only,
            },
          },
          {
            mode = { "v" },
            suffix = "D",
            tpl = "dictionary.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "(D)ictionary" },
          },
          {
            mode = { "t"},
            suffix = "t",
            tpl = "terminal.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "Terminal Command" },
            reg = {
              q = "fix the last command.",
            }
          },
        },
      },

      -- customized shortcuts
      custom_shortcuts = {
        -- An exmaple of shorcuts
        -- ["<LocalLeader>sQ"] = {
        --   mode = { "n", "v" },
        --   tpl = "question.json",
        --   target = "chat",
        --   opts = { noremap = true, silent = true, desc = "Ask (q)uestion with content" },
        -- },
      },

      -- basic features's key
      prefix = "<LocalLeader>g",
      load_reg = {
        suffix = "l",
        key = nil, -- key has higher priority than suffix if not nil
      },
      dump_reg = {
        suffix = "D",
        key = nil,
      },
      edit_reg = {
        suffix = "e",
        key = nil,
      },
      send_clipboard = {
        suffix = "s",
        key = nil,
      },
      send_chat = {
        suffix = "c",
        key = nil,
      },
      send_popup = {
        suffix = "r",
        key = nil,
      },
      send_diff = {
        suffix = "d",
        key = nil,
      },
      resume_dialog = {
        suffix = "R",
        key = nil,
      },
      load_file = {
        suffix = "p",
        key = nil,
      },
      append_file = {
        suffix = "P",
        key = nil,
      },
    },
    tpl_conf = { -- configure that will affect the rendering of the templates.
      context_len = 10, -- the number of lines before and after the current line as context
      content_max_len = 100, -- the max number of lines to show as full content
    },
  },
}

function M.setup(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options)
end

function M.get_base_dialog_keymaps()
  local keymaps = {}
  for _, k in ipairs(BASE_DIALOG_KEYMAPS) do
    keymaps[k] = M.options.dialog.keymaps[k]
  end
  return keymaps
end

function M.get_qa_dialog_keymaps()
  local keymaps = {}
  for _, k in ipairs(LOCAL_QA_DIALOG_KEYMAPS) do
    keymaps[k] = M.options.dialog.keymaps[k]
  end
  return keymaps
end

function M.get_tpl_dialog_keymaps()
  local keymaps = {}
  for _, k in ipairs(TPL_DIALOG_KEYMAPS) do
    keymaps[k] = M.options.dialog.keymaps[k]
  end
  return keymaps
end

return M
