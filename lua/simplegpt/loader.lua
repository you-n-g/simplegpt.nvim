-- Dump and load questions from disks.

-- TODO:  store data here partially
-- vim.fn.stdpath("data") .. "/config-local",

local tpl_api = require("simplegpt.tpl")
local previewers = require('telescope.previewers')

local script_path = (debug.getinfo(1, "S").source:sub(2))
local script_dir = vim.fn.fnamemodify(script_path, ":h")
local data_path = script_dir .. "/../../qa_tpls/"

-- Dump the contents of multiple registers to a file
local M = {last_tpl_name = nil}

function M.dump_reg(fname)
  local reg_values = {}
  local registers = tpl_api.get_placeholders("%l") -- only dump the registers with single letter. Placehodlers like {{q-}} will not be dumped
  table.insert(registers, "t")
  for _, reg in ipairs(registers) do
    reg_values[reg] = vim.fn.getreg(reg)
  end
  local file = io.open(data_path .. fname, "w")
  if file ~= nil then
    file:write(vim.fn.json_encode(reg_values)) -- {indent = true} does not work...
    file:close()
    print("Registers dumped successfully")
  end
end

function M.input_dump_name()
  local Input = require("nui.input")
  local event = require("nui.utils.autocmd").event

  local default_value_fname = "new_template"
  if M.last_tpl_name ~= nil then
    default_value_fname = M.last_tpl_name
  end

  local input = Input({
    position = "50%",
    size = {
      width = 40,
    },
    border = {
      style = "single",
      text = {
        top = "Filename(ignore `.json` suffix)",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    prompt = "> ",
    default_value = default_value_fname,
    on_submit = function(value)
      local fname = value .. ".json"
      M.dump_reg(fname)
      print("Saved: " .. fname)
    end,
  })

  -- mount/open the component
  input:mount()

  -- unmount component when cursor leaves buffer
  input:on(event.BufLeave, function()
    input:unmount()
  end)
end

-- Load the contents from a file into multiple registers
function M.load_reg(fname)
  M.last_tpl_name = fname:gsub("%.json$", "")
  local file = io.open(data_path .. fname, "r")
  if file ~= nil then
    local contents = file:read("*all")
    file:close()
    local reg_values = vim.fn.json_decode(contents)
    if reg_values ~= nil then
      for reg, value in pairs(reg_values) do
        vim.fn.setreg(reg, value)
      end
      print("Registers loaded successfully")
    end
  end
end

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")


function M.tele_load_reg()
  --- preview json as mark down file
  local my_custom_previewer = previewers.new({
    -- define your custom previewer here
    setup = function()
      -- setup function
    end,
    preview_fn = function(self, entry, status)
      -- preview function
      local file_path = data_path .. entry.value
      local file = io.open(file_path, "r")
      if file ~= nil then
        local contents = file:read("*all")
        file:close()
        local tpl_json = vim.fn.json_decode(contents)
        if tpl_json ~= nil then
          -- set the previewer's content
          local preview_bufnr = status.preview_bufnr
          local new_content = {}
          for _, k in ipairs(tpl_api.key_sort(tpl_json)) do  -- TODO: sort the tpl_json by keys, and put T at the first
            table.insert(new_content, "# " .. k)
            for _, line in ipairs(vim.split(tpl_json[k], "\n")) do
              table.insert(new_content, line)
            end
            table.insert(new_content, "")  -- insert a new line for each key pair
          end
          vim.api.nvim_buf_set_lines(preview_bufnr, 0, -1, false, new_content)
          vim.api.nvim_buf_set_option(preview_bufnr, 'filetype', 'markdown')

          -- NOTE: some editor may support conceallevel, you can use it to hide the json syntax
          -- set the conceallevel of the preview window
          local tabpage = vim.api.nvim_get_current_tabpage()
          local wins = vim.api.nvim_tabpage_list_wins(tabpage)
          for _, win in ipairs(wins) do  -- walk all windows in the current tabpage to get the preview window
            if vim.api.nvim_win_get_buf(win) == preview_bufnr then
              vim.api.nvim_win_set_option(win, 'conceallevel', 0)
              break
            end
          end
        end
      end
    end,
    teardown = function()
      -- teardown function
    end,
  })

  require("telescope.builtin").find_files({
    cwd = data_path,
    -- previewer = true,
    previewer = my_custom_previewer,

    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        local selection = action_state.get_selected_entry(prompt_bufnr)
        actions.close(prompt_bufnr)
        M.load_reg(selection.value)
      end)
      return true
    end,
  })
end

-- M.tele_load_reg()  -- for testing

return M
