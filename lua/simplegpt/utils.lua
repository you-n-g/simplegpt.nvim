local M = {}

function M.class(className, super)
  -- 构建类
  local clazz = { __cname = className, super = super }
  local mt = {
    __call = function(cls, ...)
      -- local instance = {}
      -- 设置对象的元表为当前类，这样，对象就可以调用当前类生命的方法了
      local self = setmetatable({}, { __index = cls })
      if cls.ctor then
        cls.ctor(self, ...)
      end
      return self
    end
  }
  if super then
    -- 设置类的元表，此类中没有的，可以查找父类是否含有
    mt.__index = super
  end
  setmetatable(clazz, mt)
  return clazz
end



-- Fast get the windows id of a buffer to support features like below.
--  local wid = M.get_win_of_buf(vim.api.nvim_get_current_buf())
--  P(vim.api.nvim_win_get_cursor(wid))
function M.get_win_of_buf(bufnr) -- get the window of the buffer
  local tabpage = vim.api.nvim_get_current_tabpage()
  local wins = vim.api.nvim_tabpage_list_wins(tabpage)
  for _, win in ipairs(wins) do  -- walk all windows in the current tabpage to get the preview window
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win
    end
  end
end



return M
