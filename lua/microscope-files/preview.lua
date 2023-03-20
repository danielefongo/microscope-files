local stream = require("microscope.stream")
local highlight = require("microscope.utils.highlight")
local utils = require("microscope-files.utils")

local preview = {}

function preview.cat(data, window)
  assert(data.file, "Provide file field")

  local cursor
  if data.col and data.row then
    cursor = { data.row, data.col }
  else
    cursor = { 1, 0 }
  end

  if not utils.exists(data.file) then
    window:write({ "Not existing" })
    return
  end

  if utils.is_binary(data.file) then
    window:write({ "Binary" })
    return
  end

  if utils.too_big(data.file) then
    window:write({ "Too big" })
    return
  end

  if preview.stream then
    preview.stream:stop()
  end

  preview.stream = stream.chain({
    { command = "cat", args = { data.file } },
  }, function(lines)
    window:write(lines)
    highlight(data.file, window.buf)
    window:set_cursor(cursor)
  end)

  preview.stream:start()
end

return preview
