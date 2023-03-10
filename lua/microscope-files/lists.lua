local utils = require("microscope-files.utils")
local files = {}

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

      return {
        text = utils.relative(data.text),
        file = filename,
        row = tonumber(elements[1]),
        col = tonumber(elements[2]),
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

      return {
        text = utils.relative(data.text),
        file = elements[1],
        row = tonumber(elements[2]),
        col = tonumber(elements[3]),
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
    args = { "--vimgrep", "-M", 200, text },
    parser = function(data)
      local elements = vim.split(data.text, ":", {})

      return {
        text = utils.relative(data.text),
        file = elements[1],
        row = tonumber(elements[2]),
        col = tonumber(elements[3]),
      }
    end,
  }
end

function files.buffergrep(text, filename)
  return {
    command = "rg",
    args = { "--vimgrep", "-M", 200, text, filename },
    parser = function(data)
      local elements = vim.split(data.text, ":", {})

      return {
        text = string.format("%s:%s: %s", elements[2], elements[3], elements[4]),
        file = elements[1],
        row = tonumber(elements[2]),
        col = tonumber(elements[3]),
      }
    end,
  }
end

return files
