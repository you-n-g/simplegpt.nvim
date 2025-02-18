local M = {}

M.format = [=[
Please suggest modification to meet the requirements. Please follow the *SEARCH/REPLACE block* Rules!!!! It is optional.
Please make it concise and less than 20 lines!!!

# *SEARCH/REPLACE block* Rules:

Every *SEARCH/REPLACE block* must use this format:
2. The opening fence and code language, eg: ```python
3. The start of search block: <<<<<<< SEARCH
4. A contiguous chunk of lines to search for in the existing source code
5. The dividing line: =======
6. The lines to replace into the source code
7. The end of the replace block: >>>>>>> REPLACE
8. The closing fence: ```


Every *SEARCH* section must *EXACTLY MATCH* the existing file content, character for character,
including all comments, docstrings, etc.
If the file contains code or other data wrapped/escaped in json/xml/quotes or other containers,
you need to propose edits to the literal contents of the file, including the container markup.

*SEARCH/REPLACE* blocks will *only* replace the first match occurrence.
Including multiple unique *SEARCH/REPLACE* blocks if needed.
Include enough lines in each SEARCH section to uniquely match each set of lines that need to change.

Keep *SEARCH/REPLACE* blocks concise.
Break large *SEARCH/REPLACE* blocks into a series of smaller blocks that each change a small portion of the file.
Include just the changing lines, and a few surrounding lines if needed for uniqueness.
Do not include long runs of unchanging lines in *SEARCH/REPLACE* blocks.

Only create *SEARCH/REPLACE* blocks for files that the user has added to the chat!

To move code within a file, use 2 *SEARCH/REPLACE* blocks: 1 to delete it from its current location,
1 to insert it in the new location.

You are diligent and tireless!
You NEVER leave comments describing code without implementing it!
You always COMPLETELY IMPLEMENT the needed code!

ONLY EVER RETURN CODE IN A *SEARCH/REPLACE BLOCK*!

Here is a example of SEARCH/REPLACE BLOCK to change a function implementation to import.

<<<<<<< SEARCH
def hello():
    "print a greeting"

    print("hello")
=======
from hello import hello

>>>>>>> REPLACE
]=]

-- extract buffers from the content of the buffer.
function M.extract_blocks(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local blocks = {}
  local i = 1
  while i <= #lines do

    if lines[i]:match("^%s*<<<+%s*SEARCH") then
      local block = {search = {}, replace = {}}
      i = i + 1
      while i <= #lines and not lines[i]:match("^===+$") do
        table.insert(block.search, lines[i])
        i = i + 1
      end
      i = i + 1
      while i <= #lines and not lines[i]:match("^>>>+%s+REPLACE$") do
        table.insert(block.replace, lines[i])
        i = i + 1
      end
      table.insert(blocks, block)
    end
    i = i + 1
  end
  return blocks
end

-- apply the search_replace_blocks into the content of the buffer number
function M.apply_blocks(bufnr, blocks)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for _, block in ipairs(blocks) do
    local s = block.search
    for j = 1, #lines - #s + 1 do
      local match = true
      for k = 1, #s do
        if lines[j + k - 1] ~= s[k] then match = false break end
      end
      if match then
        for _ = 1, #s do table.remove(lines, j) end
        for k = #block.replace, 1, -1 do table.insert(lines, j, block.replace[k]) end
        break
      end
    end
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

return M
