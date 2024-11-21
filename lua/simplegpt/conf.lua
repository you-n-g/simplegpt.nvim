-- (intention design principle) we try to handle
-- - the output format and context building (main structure) in the conf file (because it is less variable)
-- - the intention in the varibables/registers
local intentions = {
  refine = "Please refine the code. Make it more consistent (e.g., consistency among the code, document, annotation, variable naming), readable (e.g., fix typos), and standard (e.g., follow the coding linting)."
}
local M = {
  options  = {},
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
    },
    ui_map = {
      exit_keys = "exit",
      append_keys = "append",
      replace_keys = "replace",
      yank_keys = "yank",
    },
    base_dialog = {
       key_table = {
        exit_keys = {"q", "<c-c>", "<esc>"},
        cycle_next = { "<tab>" },
        cycle_prev = { "<S-Tab>" },
        yank_code = { "<C-c>" },
        extract_code = { "<C-k>" }
      }
    },
    dialog = {
      -- Dialog shortcuts
      key_table = {
        -- QA Dialog shortcuts
        -- - append the response to original buffer
        append_keys = {
          "<C-a>"
        },
        -- - replace the target(selected buffer, current line or entire file) with the response
        replace_keys = {
          "<C-r>"
        },
        -- - yank the response to clipboard
        yank_keys = {
          "<C-y>"
        },
      },
    },
    -- config about building (q)uestions
    q_build = {
      -- repository-level configs
      repo = {
        reg = "p", -- the register to inject re(p)ository-level infos
        header = "Below are some relavant files", -- the header for multiple files
      }
    },
    -- shortcuts to actions: directly loading specific template and sent to target
    shortcuts = {
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sr",
        tpl = "complete_writing_replace.json",
        target = "popup",
        opts = { noremap = true, silent = true, desc = "(R)ewrite Text" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sR",
        tpl = "complete_writing_replace.json",
        target = "diff",
        reg = {
          r = "No extra explanations. No block quotes. Output only the rewritten text. Maintain prefix spaces and indentations.",
        },
        opts = { noremap = true, silent = true, desc = "(R)ewrite Text in Diff" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sc",
        tpl = "code_complete.json",
        target = "popup",
        opts = { noremap = true, silent = true, desc = "(C)omplete Code" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sC",
        tpl = "code_complete_no_explain.json",
        target = "diff",
        opts = { noremap = true, silent = true, desc = "(C)omplete Code no explain" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sg",
        tpl = "fix_grammar.json",
        target = "diff",
        reg = {
          r = "No extra explanations. No block quotes. Output only the rewritten text. Maintain prefix spaces and indentations.",
        },
        opts = { noremap = true, silent = true, desc = "Fix (g)rammar" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sd",
        tpl = "condensing.json",
        target = "popup",
        opts = { noremap = true, silent = true, desc = "Con(d)ense" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>st",
        tpl = "continue.json",
        target = "popup",
        opts = { noremap = true, silent = true, desc = "Con(t)inue" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>se",
        tpl = "code_explain.json",
        target = "popup",
        opts = { noremap = true, silent = true, desc = "(E)xplain or Question" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sF",
        tpl = "fix_bug_with_err.json",
        target = "popup",
        opts = { noremap = true, silent = true, desc = "(F)ix errors" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sE",
        tpl = "explain_text.json",
        target = "popup",
        opts = { noremap = true, silent = true, desc = "(E)xplain Text with Trans" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sT",
        tpl = "translate.json",
        target = "popup",
        opts = { noremap = true, silent = true, desc = "(T)ranslate" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sq",
        tpl = "question.json",
        target = "chat",
        opts = { noremap = true, silent = true, desc = "Ask (q)uestion with content" },
      },
      {
        mode = { "n", "v" },
        key = "<LocalLeader>sf",
        tpl = "file_edit.json",
        target = "diff",
        opts = { noremap = true, silent = true, desc = "Edit Entire (F)ile" },
        context = {replace_target = "file"}
      },
      {
        mode = { "n" },
        key = "<LocalLeader>s<m-r>",
        tpl = "file_edit.json",
        target = "diff",
        opts = { noremap = true, silent = true, desc = "(R)efine Entire File" },
        context = {replace_target = "file"},
        reg = {
          q = intentions.refine,
        },
      },
      {
        mode = { "v" },
        key = "<LocalLeader>s<m-r>",
        tpl = "file_edit.json",
        target = "diff",
        opts = { noremap = true, silent = true, desc = "(R)efine selection" },
        reg = {
          q = intentions.refine,
        },
      },
    },
    tpl_conf = {  -- configure that will affect the rendering of the templates.
      context_len = 10,  -- the number of lines before and after the current line as context
      content_max_len = 100, -- the max number of lines to show as full content
    }
  }
}


function M.setup(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options)
end

return M
