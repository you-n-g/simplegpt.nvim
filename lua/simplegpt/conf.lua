-- (intention design principle) we try to handle
-- - the output format and context building (main structure) in the conf file (because it is less variable)
-- - the intention in the varibables/registers
local intentions = {
	refine = "Please refine the code. Make it more consistent (e.g., consistency among the code, document, annotation, variable naming), readable (e.g., fix typos), and standard (e.g., follow the coding linting).",
}

local BASE_DIALOG_KEYMAPS = {
	"exit_keys",
	"cycle_next",
	"cycle_prev",
	"yank_code",
	"extract_code",
  "show_value",
}
local LOCAL_QA_DIALOG_KEYMAPS = {
	"append_keys",
	"replace_keys",
	"yank_keys",
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
				exit_keys = "exit",
				append_keys = "append",
				replace_keys = "replace",
				yank_keys = "yank",
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
			},
		},
		-- config about building (q)uestions
		q_build = {
			-- repository-level configs
			repo = {
				reg = "p", -- the register to inject re(p)ository-level infos
				header = "Below are some relavant files", -- the header for multiple files
			},
		},
		keymaps = { -- these are keymap that does not belong to a specific conponent like dialog.
			-- shortcuts to actions: directly loading specific template and sent to target(they are often concrete applications)
			shortcuts = {
				-- prefix = "<m-g>", -- I think this would be more convenient.
				prefix = "<LocalLeader>s",
				list = { -- prefix is not here
					{
						mode = { "n", "v" },
						suffix = "r",
						tpl = "complete_writing_replace.json",
						target = "popup",
						opts = { noremap = true, silent = true, desc = "(R)ewrite Text" },
					},
					{
						mode = { "n", "v" },
						suffix = "R",
						tpl = "complete_writing_replace.json",
						target = "diff",
						reg = {
							r = "No extra explanations. No block quotes. Output only the rewritten text. Maintain prefix spaces and indentations.",
						},
						opts = { noremap = true, silent = true, desc = "(R)ewrite Text in Diff" },
					},
					{
						mode = { "n", "v" },
						suffix = "c",
						tpl = "code_complete.json",
						target = "popup",
						reg = {
							q = "Please fix all the errors and complete all the missing feature in the focused part.\nYou don't have to output the complete code. You can output the key part with some extra context."
						},
						opts = { noremap = true, silent = true, desc = "(C)omplete Code" },
					},
					{
						mode = { "n", "v" },
						suffix = "C",
						tpl = "code_complete.json",
						target = "diff",
						reg = {
							q = "Please fix all the errors and complete all the missing feature in the focused part.\nNo extra explanations.\nNo block quotes. DO NOT include three backticks ``` in the code. Try to keep all the comments (You can modify them to make it better).\nKeep original indent so that we can replace the original code with the newly generated one."
						},
						opts = { noremap = true, silent = true, desc = "(C)omplete Code no explain" },
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
						tpl = "file_edit.json",
						target = "diff",
						opts = { noremap = true, silent = true, desc = "(R)efine selection" },
						reg = {
							q = intentions.refine,
						},
					},
				},
			},

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

return M
