local files = {}

local function extend_args(args, extra_args)
  if extra_args.hidden then
    table.insert(args, 1, "--hidden")
  end
  return args
end

function files.rg()
  return {
    fun = function(flow, _, args)
      flow.consume(flow.cmd.shell("rg", extend_args({ "--files" }, args)))
    end,
    args = { hidden = false },
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
    fun = function(flow, request, args)
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
        flow.cmd.shell(
          "rg",
          extend_args({ "--color", "never", "--line-number", "--column", "-M", 200, "-S", prefilter }, args)
        )
      )
    end,
  }
end

function files.vimgrep()
  return {
    fun = function(flow, request, args)
      if request.text == "" then
        return flow.write("")
      end

      flow.consume(flow.cmd.shell("rg", extend_args({ "--vimgrep", "-S", "-M", 200, request.text }, args)))
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
