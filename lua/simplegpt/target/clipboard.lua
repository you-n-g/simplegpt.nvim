M = {}

function M.build_q_handler(context)
  return function (question)
    for _, reg in ipairs({ '"', "+" }) do
      vim.fn.setreg(reg, question)
    end
    print("content sent to clipboard.")
  end
end

return M
