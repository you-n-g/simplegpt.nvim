local M = {}

function M.build_q_handler(context)
  return function(question)
    require"simplegpt.buf_chat".create_chat_buffer({{role="user", content=question}}, true)
  end
end

return M
