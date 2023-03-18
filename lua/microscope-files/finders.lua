local open = require("microscope-files.open")
local preview = require("microscope-files.preview")
local file_steps = require("microscope-files.steps")
local steps = require("microscope.steps")

return {
  workspace_grep = {
    open = open,
    preview = preview.cat,
    chain = function(text)
      return { file_steps.vimgrep(text), steps.head(100) }
    end,
  },
  workspace_fuzzy = {
    open = open,
    preview = preview.cat,
    chain = function(text)
      return { file_steps.all_lines(), steps.fzf(text), steps.head(100) }
    end,
  },
  buffer_grep = {
    open = open,
    preview = preview.cat,
    chain = function(text, _, buf)
      local filename = vim.api.nvim_buf_get_name(buf)
      return { file_steps.buffergrep(text, filename), steps.head(100) }
    end,
  },
  buffer_fuzzy = {
    open = open,
    preview = preview.cat,
    chain = function(text, _, buf)
      local filename = vim.api.nvim_buf_get_name(buf)
      return { file_steps.buffer_lines(filename), steps.fzf(text) }
    end,
  },
  old_file = {
    open = open,
    preview = preview.cat,
    chain = function(text)
      return { file_steps.old_files(), steps.fzf(text), steps.head(100) }
    end,
  },
  file = {
    open = open,
    preview = preview.cat,
    chain = function(text)
      return { file_steps.rg(), steps.fzf(text), steps.head(100) }
    end,
  },
}
