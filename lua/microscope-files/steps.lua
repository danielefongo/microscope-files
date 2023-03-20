local utils = require("microscope-files.utils")
local highlight = require("microscope.highlight")
local constants = require("microscope.constants")
local files = {}

local function highlight_file_cursor(highlights, text, query)
  query = query or ""
  return highlight
    .new(highlights, text)
    :hl_match(constants.color.color1, "(.*:)(%d+:%d+:)(.*)", 1)
    :hl_match(constants.color.color2, "(.*:)(%d+:%d+:)(.*)", 2)
    :hl_match(constants.color.match, "(.*)(%d+:%d+:)(.*)(" .. query .. ")(.*)", 4)
    :get_highlights()
end

local function highlight_cursor(highlights, text, query)
  query = query or ""
  return highlight
    .new(highlights, text)
    :hl_match(constants.color.color2, "(%d+:%d+:)(.*)", 1)
    :hl_match(constants.color.match, "(%d+:%d+:)(.*)(" .. query .. ")(.*)", 3)
    :get_highlights()
end

function files.rg()
  return {
    command = "rg",
    args = { "--files", "--color", "never" },
    parser = function(data)
      return {
        text = utils.relative(data.text),
        file = data.text,
      }
    end,
  }
end

function files.buffer_lines(filename)
  return {
    command = "rg",
    args = { "--no-filename", "--color", "never", "--line-number", "--column", "", filename },
    parser = function(data)
      local elements = vim.split(data.text, ":", {})
      local line_text = string.gsub(data.text, table.concat({ elements[1], elements[2] }, ":"), "")

      return {
        text = utils.relative(data.text),
        highlights = highlight_cursor(data.highlights, data.text),
        file = filename,
        row = tonumber(elements[1]),
        col = tonumber(elements[2]),
        line_text = line_text,
      }
    end,
  }
end

function files.all_lines()
  return {
    command = "rg",
    args = { "--color", "never", "--line-number", "--column", "" },
    parser = function(data)
      local elements = vim.split(data.text, ":", {})
      local limited_path = utils.relative(data.text)
      local line_text = string.gsub(data.text, table.concat({ elements[1], elements[2], elements[3] }, ":"), "")

      return {
        text = limited_path,
        highlights = highlight_file_cursor(data.highlights, limited_path),
        file = elements[1],
        row = tonumber(elements[2]),
        col = tonumber(elements[3]),
        line_text = line_text,
      }
    end,
  }
end

function files.old_files()
  return {
    fun = function(on_data)
      on_data(vim.v.oldfiles)
    end,
    parser = function(data)
      return {
        text = utils.relative(data.text),
        file = data.text,
      }
    end,
  }
end

function files.vimgrep(text)
  return {
    command = "rg",
    args = { "--vimgrep", "-S", "-M", 200, text },
    parser = function(data)
      local elements = vim.split(data.text, ":", {})
      local limited_path = utils.relative(data.text)
      local line_text = string.gsub(data.text, table.concat({ elements[1], elements[2], elements[3] }, ":"), "")

      return {
        text = limited_path,
        highlights = highlight_file_cursor(data.highlights, limited_path, text),
        file = elements[1],
        row = tonumber(elements[2]),
        col = tonumber(elements[3]),
        line_text = line_text,
      }
    end,
  }
end

function files.buffergrep(text, filename)
  return {
    command = "rg",
    args = { "--vimgrep", "--no-filename", "-S", "-M", 200, text, filename },
    parser = function(data)
      local elements = vim.split(data.text, ":", {})
      local line_text = string.gsub(data.text, table.concat({ elements[1], elements[2] }, ":"), "")

      return {
        text = data.text,
        highlights = highlight_cursor(data.highlights, data.text, text),
        file = filename,
        row = tonumber(elements[1]),
        col = tonumber(elements[2]),
        line_text = line_text,
      }
    end,
  }
end

return files
