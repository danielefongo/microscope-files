local files = {}

function files.rg()
  return {
    fun = function(flow)
      flow.spawn({
        cmd = "rg",
        args = { "--files" },
      })
    end,
  }
end

function files.buffer_lines()
  return {
    fun = function(flow, request)
      local filename = flow.fn(vim.api.nvim_buf_get_name, request.buf)
      flow.spawn({
        cmd = "rg",
        args = { "--no-filename", "--color", "never", "--line-number", "--column", "", filename },
      })
    end,
  }
end

function files.prefiltered_all_lines()
  return {
    fun = function(flow, request, context)
      local text = request.text:gsub("%s+", " ")

      if #text < 3 then
        context.cache = nil
        return flow.spawn({ cmd = "echo" })
      end

      if context.cache then
        return flow.write(context.cache)
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
          prefilter = prefilter .. "|"
          new_word = true
        else
          prefilter = prefilter .. ".*" .. char
        end
      end
      prefilter = prefilter .. ")"

      context.cache = flow.command({
        cmd = "rg",
        args = { "--color", "never", "--line-number", "--column", "-M", 200, "-S", prefilter },
      })

      flow.write(context.cache)
    end,
  }
end

function files.vimgrep()
  return {
    fun = function(flow, request)
      flow.spawn({
        cmd = "rg",
        args = { "--vimgrep", "-S", "-M", 200, request.text },
      })
    end,
  }
end

function files.buffergrep()
  return {
    fun = function(flow, request)
      local filename = flow.fn(vim.api.nvim_buf_get_name, request.buf)
      flow.spawn({
        cmd = "rg",
        args = { "--vimgrep", "--no-filename", "-S", "-M", 200, request.text, filename },
      })
    end,
  }
end

return files
