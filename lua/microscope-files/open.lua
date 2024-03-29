return function(data, request)
  assert(data.file, "Provide file field")

  vim.cmd("normal! m'")

  local full_path = vim.fn.fnamemodify(data.file, ":p")
  local buffer = vim.fn.bufnr(full_path, true)
  vim.api.nvim_buf_set_option(buffer, "buflisted", true)
  vim.api.nvim_win_set_buf(request.win, buffer)

  if data.row and data.col then
    local cursor = { data.row, data.col }
    vim.api.nvim_win_set_cursor(request.win, cursor)
  end
end
