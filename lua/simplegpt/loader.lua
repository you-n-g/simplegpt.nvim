-- Dump and load questions from disks.

-- TODO:  store data here partially
-- vim.fn.stdpath("data") .. "/config-local",

local tpl_api = require("simplegpt.tpl")
local previewers = require('telescope.previewers')

local script_path = (debug.getinfo(1, "S").source:sub(2))
local script_dir = vim.fn.fnamemodify(script_path, ":h")
local conf = require("simplegpt.conf")
local custom_template_path = conf.options.custom_template_path and vim.fn.expand(conf.options.custom_template_path)

if custom_template_path and not vim.loop.fs_stat(custom_template_path) then
  vim.loop.fs_mkdir(custom_template_path, 493)  -- 493 is the octal representation of 0755
end

local template_path = script_dir .. "/../../qa_tpls/"

local M = {last_tpl_name = nil}

-- Open the first existing file.
-- If not exist, return io.open in customized file
local function try_open_file(fname, mode)
  local file_path = template_path .. fname
  local is_new_file = not vim.loop.fs_stat(file_path)
  local source = "default"

  if is_new_file and custom_template_path then
    file_path = custom_template_path .. fname
    is_new_file = not vim.loop.fs_stat(file_path)
    source = "custom"
  end

  local file = io.open(file_path, mode)
  print(file_path, is_new_file)
  return file, file_path, source, is_new_file
end

function M.dump_reg(fname)
  local reg_values = {}
  local registers = tpl_api.get_placeholders("%l")
  table.insert(registers, "t")
  for _, reg in ipairs(registers) do
    reg_values[reg] = vim.fn.getreg(reg)
  end

  local file, file_path, source = try_open_file(fname, "w")
  if file then
    file:write(vim.fn.json_encode(reg_values))
    file:close()
    print("Registers dumped successfully to " .. source)
  else
    print("Failed to open file for writing: " .. fname)
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
      M.last_tpl_name = fname
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
  local file, file_path, source = try_open_file(fname, "r")
  if file then
    local contents = file:read("*all")
    file:close()
    local reg_values = vim.fn.json_decode(contents)
    if reg_values then
      for reg, value in pairs(reg_values) do
        vim.fn.setreg(reg, value)
      end
      print("Registers loaded successfully from " .. source)
    end
  else
    print("Failed to open file for reading: " .. fname)
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
      local file_path = template_path .. entry.value
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
    cwd = template_path,
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
