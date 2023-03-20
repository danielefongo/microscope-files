return function(data, win, _)
  assert(data.file, "Provide file field")

  vim.cmd("e " .. data.file)
  if data.row and data.col then
    local cursor = { data.row, data.col }
    vim.api.nvim_win_set_cursor(win, cursor)
  end
end
