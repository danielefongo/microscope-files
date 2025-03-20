local scope = require("microscope.api.scope")
local treesitter = require("microscope.api.treesitter")
local utils = require("microscope-files.utils")

local preview = {}

function preview.cat(data, window)
  assert(data.file, "Provide file field")

  if preview.scope then
    preview.scope:stop()
  end

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

  preview.scope = scope.new({
    lens = {
      fun = function(flow, text)
        flow.consume(flow.cmd.shell("cat", { text }))
      end,
    },
    callback = function(lines)
      window:write(lines)

      local hls = treesitter.for_buffer(window.buf, vim.filetype.match({ filename = data.file, buf = window.buf }))
      window:clear_buf_hls()
      window:set_buf_hls(hls)
      window:set_cursor(cursor)
      if cursor[2] > 0 then
        window:set_buf_hl("Search", cursor[1], cursor[2], cursor[2])
      end
    end,
  })

  preview.scope:search(data.file)
end

return preview
