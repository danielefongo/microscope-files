local files = {}

function files.rg()
  return {
    fun = function(flow)
      flow.consume(flow.cmd.shell("rg", { "--files" }))
    end,
  }
end

function files.buffer_lines()
  return {
    fun = function(flow, request)
      flow.consume(
        flow.cmd
          .fn(vim.api.nvim_buf_get_name, request.buf)
          :pipe("xargs", { "rg", "--no-filename", "--color", "never", "--line-number", "--column", "" })
      )
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

      flow.consume(
        flow.cmd.shell("rg", { "--color", "never", "--line-number", "--column", "-M", 200, "-S", prefilter })
      )
    end,
  }
end

function files.vimgrep()
  return {
    fun = function(flow, request)
      if request.text == "" then
        return flow.write("")
      end

      flow.consume(flow.cmd.shell("rg", { "--vimgrep", "-S", "-M", 200, request.text }))
    end,
  }
end

function files.buffergrep()
  return {
    fun = function(flow, request)
      if request.text == "" then
        return flow.write("")
      end
      flow.consume(
        flow.cmd
          .fn(vim.api.nvim_buf_get_name, request.buf)
          :pipe("xargs", { "rg", "--vimgrep", "--no-filename", "-s", "-m", 200, request.text })
      )
    end,
  }
end

return files
