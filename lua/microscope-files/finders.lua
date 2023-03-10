local open = require("microscope-files.open")
local preview = require("microscope-files.preview")
local file_lists = require("microscope-files.lists")
local lists = require("microscope.lists")

return {
  workspace_grep = {
    open = open,
    preview = preview.cat,
    chain = function(text)
      return { file_lists.vimgrep(text), lists.head(100) }
    end,
  },
  workspace_fuzzy = {
    open = open,
    preview = preview.cat,
    chain = function(text)
      return { file_lists.all_lines(), lists.fzf(text) }
    end,
  },
  buffer_grep = {
    open = open,
    preview = preview.cat,
    chain = function(text, _, buf)
      local filename = vim.api.nvim_buf_get_name(buf)
      return { file_lists.buffergrep(text, filename), lists.head(100) }
    end,
  },
  buffer_fuzzy = {
    open = open,
    preview = preview.cat,
    chain = function(text, _, buf)
      local filename = vim.api.nvim_buf_get_name(buf)
      return { file_lists.buffer_lines(filename), lists.fzf(text) }
    end,
  },
  old_file = {
    open = open,
    preview = preview.cat,
    chain = function(text)
      return { file_lists.old_files(), lists.fzf(text), lists.head(100) }
    end,
  },
  file = {
    open = open,
    preview = preview.cat,
    chain = function(text)
      return { file_lists.rg(), lists.fzf(text), lists.head(100) }
    end,
  },
}
