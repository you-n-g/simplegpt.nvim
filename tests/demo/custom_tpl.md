# Customized your folder

```lua
{
  "you-n-g/simplegpt.nvim",
  -- ... more config
  opts = {
    keymaps = {
      custom_shortcuts = {
        ["<localleader>st"] = {
          mode = { "v" },
          tpl = "converter.json",
          target = "diff",
          opts = { noremap = true, silent = true, desc = "Convert between YAML & JSON" },
        },
      },
      -- ... more config
    },
    custom_template_path = "~/deploy/configs/lazynvim/data/tpl/",
  },
  -- ... more config
}
```

# Load the text as template into register t via `"ty`
You have a file with the following content:
```
{{visual}}
```
If it is in JSON format, please convert it to YAML. If it is in YAML format, please convert it to JSON.
Don't give any extra explanation.

# Dump it to converter.json via `<localleader>gD`
`!cat ~/deploy/configs/lazynvim/data/tpl/converter.json`
{"t": "You have a file with the following content:\n```\n{{visual}}\n```\nIf it is in JSON format, please convert it to YAML. If it is in YAML format, please convert it to JSON.\nDon't give any extra explanation.\n"}

# Test your customized prompts for your tasks.
```json
{
  "good": "foo",
  "bad": "bar"
}
```
It is converted back now!
