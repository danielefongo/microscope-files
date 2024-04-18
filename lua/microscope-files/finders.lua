local open = require("microscope-files.open")
local preview = require("microscope-files.preview")
local file_lenses = require("microscope-files.lenses")
local lenses = require("microscope.builtin.lenses")
local file_parsers = require("microscope-files.parsers")
local parsers = require("microscope.builtin.parsers")

return {
  workspace_grep = {
    lens = lenses.head(file_lenses.vimgrep()),
    open = open,
    preview = preview.cat,
    parsers = { file_parsers.file_row_col, file_parsers.regex },
  },
  workspace_fuzzy = {
    lens = lenses.head(lenses.fzf(file_lenses.prefiltered_all_lines())),
    open = open,
    preview = preview.cat,
    parsers = { file_parsers.file_row_col, parsers.fuzzy },
    args = { limit = 500 },
  },
  buffer_grep = {
    lens = lenses.head(file_lenses.buffergrep()),
    open = open,
    preview = preview.cat,
    parsers = { file_parsers.row_col, file_parsers.regex },
  },
  buffer_fuzzy = {
    lens = lenses.head(lenses.fzf(lenses.cache(file_lenses.buffer_lines()))),
    open = open,
    preview = preview.cat,
    parsers = { file_parsers.row_col, parsers.fuzzy },
    args = { limit = 500 },
  },
  file = {
    lens = lenses.head(lenses.fzf(lenses.cache(file_lenses.rg()))),
    open = open,
    preview = preview.cat,
    parsers = { file_parsers.file, parsers.fuzzy },
  },
}
