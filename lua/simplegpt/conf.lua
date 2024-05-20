M = {
  options  = {},
  defaults = {
    dialog = {
      -- Dialog shortcuts
      -- - close a dialog
      exit_keys = {
        "q", "<c-c>", "<esc>"
      },
      -- QA Dialog shortcuts
      -- - append the response to original buffer
      append_keys = {
        "<C-a>"
      },
      -- - replace the selected buffer (or current line) with the response
      replace_keys = {
        "<C-r>"
      },
      -- - yank the response to clipboard
      yank_keys = {
        "<C-y>"
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
        key = "<LocalLeader>sf",
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
    }
  }
}


function M.setup(options)
  options = options or {}
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options)
end

return M
