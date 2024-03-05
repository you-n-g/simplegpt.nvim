local M = {}

function M.build_q_handler(context)
  return function(question)
    local chat_api = require("chatgpt.flows.chat")
    chat_api:open()
    local bufnr = chat_api.chat.chat_input.bufnr
    -- remove all content in bufnr and set the content to quesetion
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(question, "\n"))

    -- set bufnr to normal mode
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_command([[normal! \<Esc>]])
    print("content sent to chatgpt.")
  end
end

return M
