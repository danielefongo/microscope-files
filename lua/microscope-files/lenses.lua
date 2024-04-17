local files = {}

function files.rg()
  return {
    fun = function(flow)
      flow.cmd.shell("rg", { "--files" }):into(flow)
    end,
  }
end

function files.buffer_lines()
  return {
    fun = function(flow, request)
      local filename = flow.cmd.fn(vim.api.nvim_buf_get_name, request.buf):collect()
      flow.cmd
        .shell("rg", { "--no-filename", "--color", "never", "--line-number", "--column", "", filename })
        :into(flow)
    end,
  }
end

function files.prefiltered_all_lines()
  return {
    fun = function(flow, request)
      local text = request.text:gsub("%s+", " ")

      if #text < 3 then
        return flow.write("")
      end

      local prefilter = ""

      local new_word = true
      prefilter = "("
      for text_idx = 1, #text, 1 do
        local char = string.sub(text, text_idx, text_idx)
        if string.match(char, "[%.%+%*%?%^%$%(%)%[%]%{%}%|%\\]") then
          char = "\\" .. char
        end

        if new_word then
          prefilter = prefilter .. char
          new_word = false
        elseif string.sub(text, text_idx, text_idx) == " " then
          prefilter = prefilter .. ")|("
          new_word = true
        else
          prefilter = prefilter .. ".*" .. char
        end
      end
      prefilter = prefilter .. ")"

      flow.cmd.shell("rg", { "--color", "never", "--line-number", "--column", "-M", 200, "-S", prefilter }):into(flow)
    end,
  }
end

function files.vimgrep()
  return {
    fun = function(flow, request)
      flow.cmd.shell("rg", { "--vimgrep", "-S", "-M", 200, request.text }):into(flow)
    end,
  }
end

function files.buffergrep()
  return {
    fun = function(flow, request)
      local filename = flow.cmd.fn(vim.api.nvim_buf_get_name, request.buf):collect()
      flow.cmd.shell("rg", { "--vimgrep", "--no-filename", "-s", "-m", 200, request.text, filename }):into(flow)
    end,
  }
end

return files
