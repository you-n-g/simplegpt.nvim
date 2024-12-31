-- Dump and load questions from disks.

-- TODO:  store data here partially
-- vim.fn.stdpath("data") .. "/config-local",

local tpl_api = require("simplegpt.tpl")

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
      M.last_tpl_name = value
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
  -- If fname is a path, only keep the last part (e.g. the name)
  fname = vim.fn.fnamemodify(fname, ":t")
  M.last_tpl_name = fname:gsub("%.json$", "")
  local file, _, source = try_open_file(fname, "r")
  if file then
    local contents = file:read("*all")
    file:close()
    local reg_values = vim.fn.json_decode(contents)
    if reg_values then
      for reg, value in pairs(reg_values) do
        vim.fn.setreg(reg, value)
      end
      if source then
        print("Registers loaded successfully from " .. source)
      end
    end
  else
    print("Failed to open file for reading: " .. fname)
  end
end

-- Specialized head previewer
-- Previewer.head = Previewer.cmd:extend()
--
-- function Previewer.head:new(o, opts)
--   Previewer.head.super.new(self, o, opts)
--   return self
-- end
--
-- function Previewer.head:cmdline(o)
--   o = o or {}
--   o.action = o.action or self:action(o)
--   local lines = "--lines=-0"
--   -- print all lines instead
--   -- if self.opts.line_field_index then
--   --   lines = string.format("--lines=%s", self.opts.line_field_index)
--   -- end
--   return self:format_cmd(self.cmd, self.args, o.action, lines)
-- end

function M.tele_load_reg()
  --- preview json as markdown file

  local search_paths = { string.format("'%s'", template_path) }
  if custom_template_path then
    table.insert(search_paths, string.format("'%s'", custom_template_path))
  end

  local cmd = "find " .. table.concat(search_paths, " ") .. " -type f"

  require('fzf-lua').files({
    search_dirs = search_paths,
    -- cmd = "ls " .. table.concat(search_paths, " "),
    cmd = cmd,
    -- cwd = template_path,
    -- previewer = my_custom_previewer,
    -- fzf --preview 'jq -r '\''def to_markdown: . as $in | if type == "object" then to_entries | map("## \(.key)\n" + (if .value | type == "object" then (.value | to_markdown) else "- **\(.key)**: \(.value|tostring)" end)) | .[] else "- **\($in|tostring)**" end; . | to_markdown'\'' {}' --preview-window=right:60%
    -- previewer = ...,  -- TODO: add json to markdown previewer
    actions = {
      ["default"] = function(selected)
        M.load_reg(selected[1])
      end,
    },
  })
end

-- M.tele_load_reg()  -- for testing

return M
