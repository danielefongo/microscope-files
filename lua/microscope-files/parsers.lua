local utils = require("microscope-files.utils")
local highlight = require("microscope.api.highlight")
local treesitter = require("microscope.api.treesitter")

local parsers = {}

function parsers.file(data, _)
  data.file = utils.relative(data.text)
  return data
end

function parsers.file_row_col(data, _)
  local elements = vim.split(data.text, ":", {})
  local limited_path = utils.relative(data.text)
  local line_text = string.gsub(data.text, table.concat({ elements[1], elements[2], elements[3] }, ":"), "")
  local lang = vim.filetype.match({ filename = elements[1], buf = 0 })
  local highlights = highlight
    .new(data.highlights, limited_path)
    :hl_match(highlight.color.color1, "(.*:)(%d+:%d+:)(.*)", 1)
    :hl_match(highlight.color.color2, "(.*:)(%d+:%d+:)(.*)", 2)
    :hl_match_with(function(text)
      return treesitter.for_text(text, lang)
    end, "(.*:)(%d+:%d+:)(.*)", 3)
    :get_highlights()

  return {
    text = limited_path,
    highlights = highlights,
    file = elements[1],
    row = tonumber(elements[2]),
    col = tonumber(elements[3]),
    line_text = line_text,
  }
end

function parsers.row_col(data, request)
  local elements = vim.split(data.text, ":", {})
  local line_text = string.gsub(data.text, table.concat({ elements[1], elements[2] }, ":"), "")
  local filename = vim.api.nvim_buf_get_name(request.buf)
  local lang = vim.filetype.match({ filename = filename, buf = 0 })
  local highlights = highlight
    .new(data.highlights, data.text)
    :hl_match(highlight.color.color2, "(%d+:%d+:)(.*)", 1)
    :hl_match_with(function(text)
      print(text)
      return treesitter.for_text(text, lang)
    end, "(%d+:%d+:)(.*)", 2)
    :get_highlights()

  return {
    text = data.text,
    highlights = highlights,
    file = filename,
    row = tonumber(elements[1]),
    col = tonumber(elements[2]),
    line_text = line_text,
  }
end

function parsers.regex(data, request)
  local query = request.text or ""

  data.highlights = highlight
    .new(data.highlights, data.text:lower())
    :hl_match(highlight.color.match, "(.*)(%d+:%d+:)(.*)(" .. query:lower() .. ")(.*)", 4)
    :get_highlights()

  return data
end

return parsers
