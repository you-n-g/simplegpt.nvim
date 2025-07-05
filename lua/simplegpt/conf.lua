-- (intention design principle) we try to handle
-- - the output format and context building (main structure) in the conf file (because it is less variable)
-- - the intention in the varibables/registers
local intentions = {
  refine = "Please refine the code. Make it more consistent (e.g., consistency among the code, document, annotation, variable naming), readable (e.g., fix typos), and standard (e.g., follow the coding linting).",
  -- rules
  mod_on_conversation="When we have multiple loops of conversations, don't assume that previous modifications have been made. You are still changing the initial version of the code.",
}


-- describe the designed format
local format = {
  code_only = "No extra explanations.\nNo block quotes. DO NOT include three backticks ``` in the code. Try to keep all the comments (You can modify them to make it better).\nKeep original indent so that we can replace the original code with the newly generated one." .. "\n" .. intentions.mod_on_conversation,
  search_replace=require"simplegpt.search_replace".format .. "\n" .. intentions.mod_on_conversation,
  text_rewrite="No extra explanations. No block quotes. Output only the rewritten text. Maintain prefix spaces and indentations.",
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
  "buffer_chat_keys",
  -- "", restore to default value
}
local LOCAL_QA_DIALOG_KEYMAPS = {
  "append_keys",
  "replace_keys",
  "yank_keys",
  "chat_keys",
  "search_replace",
  "nav_ans",
  "buffer_chat_keys",
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
        buffer_chat_keys = "buffer chat",
        append_keys = "append",
        replace_keys = "replace",
        yank_keys = "yank",
        chat_keys = "chat",
        search_replace = "apply S&R",
      },
    },
    dialog = {
      -- Dialog keymaps
      keymaps = {
        show_value = { "K" }, -- Default key for showing special value
        -- Base Dialog shortcuts
        exit_keys = { "q", "<c-c>", "<esc>" },
        buffer_chat_keys = {"Q"},
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
        -- - apply search and replace
        search_replace = { "<m-r>" },
        nav_ans = { "[]" },  -- Please note it is a pair of keys. The first key is for nav  back and the second key is for nav forward
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
              f = format.text_rewrite,
            },
            opts = { noremap = true, silent = true, desc = "(R)ewrite Text in Diff" },
          },
          {
            mode = { "n", "v" },
            suffix = "C",
            tpl = "code_complete.json",
            target = "popup",
            reg = {
              f = "You don't have to output the complete code. You can output the key part with some extra context.",
              q = "Please fix all the errors and complete all the missing feature in the focused part.",
            },
            opts = { noremap = true, silent = true, desc = "(C)omplete Code" },
          },
          {
            mode = { "n", "v" },
            suffix = "c",
            tpl = "code_complete.json",
            target = "diff",
            reg = {
              q = "Please fix all the errors and complete all the missing feature in the focused part.\n",
              f = "Format requirements:\n" .. format.code_only,
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
            mode = { "v" },
            suffix = "k",
            tpl = "code_complete.json",
            target = "diff",
            reg = {
              f = format.code_only .. "\n" .. "Only return the signature and the document.",
              q = "Please add detailed document for the function you are focusing.\n"
                .. "The document should include the type and a conceret example of each variable and the return type.\n"
            },
            opts = { noremap = true, silent = true, desc = "Add do(c) for the function." },
          },
          {
            mode = { "v", "n" },
            suffix = "v",
            tpl = "variable_explain.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "Add Doc For (V)ariable" },
          },
          {
            mode = { "n", "v" },
            suffix = "g",
            tpl = "fix_grammar.json",
            target = "diff",
            reg = {
              f = format.text_rewrite,
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
            reg = {
              q = "Please explain the part you are focusing.",
            },
          },
          {
            mode = { "n", "v" },
            suffix = "b",
            tpl = "code_explain.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "Find (B)ug." },
            reg = {
              q = "Can you find any bugs in the current script that could cause it to fail during execution?\nPlease list bugs that are certain to cause failure first, followed by potential bugs you think might occur. Rank the bugs by their likelihood of causing issues, starting with the most probable."
            },
          },
          {
            mode = { "n"},
            suffix = "F",
            tpl = "fix_bug_with_err.json",
            target = "popup",
            reg = {
              f = format.search_replace,
            },
            opts = { noremap = true, silent = true, desc = "(F)ix errors" },
          },
          {
            mode = { "v" },
            suffix = "F",
            tpl = "fix_bug_with_err.json",
            target = "diff",
            reg = {
              f = format.code_only,
            },
            opts = { noremap = true, silent = true, desc = "(F)ix errors for selected text" },
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
            tpl = "code_complete.json",
            target = "diff",
            opts = { noremap = true, silent = true, desc = "Edit Entire (F)ile" },
            context = { replace_target = "file" },
            reg = {
              f = "Please output the entire content to replace the file to be edit.\n" .. format.code_only,
            },
          },
          {
            mode = { "n", "v" },
            suffix = "<m-f>",
            tpl = "code_complete.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "Edit (F)ile with SEARCH/REPLACE block" },
            -- context = { replace_target = "file" },
            reg = {
              f = format.search_replace
            },
          },
          {
            mode = { "v", "n" },
            suffix = "<m-r>",
            tpl = "code_complete_w_lsp.json",
            target = "diff",
            opts = { noremap = true, silent = true, desc = "(R)efine code" },
            reg = {
              q = intentions.refine, 
              f = format.code_only,
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
          {
            mode = { "t"},
            suffix = "r",
            tpl = "code_review.json",
            target = "popup",
            opts = { noremap = true, silent = true, desc = "Terminal Command" },
          },
        },
      },

      -- customized shortcuts
      custom_shortcuts = {
        -- An exmaple of shorcuts
        -- {
        --   key = "<LocalLeader>sQ"
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
        suffix = "Q",
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
      chat_complete = { -- for buffer chat
        suffix = "c",
        key = nil,
      },
    },
    tpl_conf = { -- configure that will affect the rendering of the templates.
      context_len = 10, -- the number of lines before and after the current line as context
      content_max_len = 100, -- the max number of lines to show as full content
    },
    buffer_chat = {
      user_emoji = '👤',  -- User emoji (👤)
      ai_emoji = '🤖',    -- AI emoji (🤖)
      system_emoji = '💻', -- System emoji (💻) - computer
      default_system_prompt = 'You are a helpful AI assistant.', -- Default prompt used when no system prompt is present
      provider = nil, -- The provider to buffer chat
    },
  },
}

-- This function retrieves the basic keymaps for a given name.
-- It first checks if a specific key is defined for the name.
-- If not, it constructs the keymap using a prefix and suffix associated with the name.
function M.get_basic_keymaps(name)
    local km = M.options.keymaps
    return km[name].key or km.prefix .. km[name].suffix
end

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
