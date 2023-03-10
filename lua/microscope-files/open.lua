return function(data, win, _)
  vim.cmd("e " .. data.file)
  if data.row and data.col then
    local cursor = { data.row, data.col }
    vim.api.nvim_win_set_cursor(win, cursor)
  end
end
