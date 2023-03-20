local actions = {}

local function to_qf(data)
  assert(data.file, "Provide file field")

  return { filename = data.file, lnum = data.row, col = data.col, text = data.line_text }
end

function actions.quickfix(microscope)
  local results = microscope.results:selected()
  vim.fn.setqflist(vim.tbl_map(to_qf, results))
  vim.api.nvim_command("copen")
end

return actions
