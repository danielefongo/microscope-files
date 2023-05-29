local utils = {}
utils.max_size = 2 ^ 16

function utils.exists(path)
  local file = vim.loop.fs_open(path, "r", 438)
  if file == nil then
    return false
  end
  vim.loop.fs_close(file)
  return true
end

function utils.too_big(path)
  local file = vim.loop.fs_open(path, "r", 438)
  local file_size = vim.loop.fs_fstat(file).size
  vim.loop.fs_close(file)
  return file_size > utils.max_size
end

function utils.is_binary(path)
  local handle = io.popen(string.format("file -n -b --mime-encoding '%s'", path))
  if not handle then
    return false
  end
  local binary_file = handle:read("*a"):match("binary")

  handle:close()
  return binary_file
end

function utils.relative(path)
  local current_path = vim.fn.getcwd():gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1") .. "/"
  return string.gsub(path, current_path, "")
end

return utils
