local M = {}

local key = {
  bs = "<BS>",
  cr = "<CR>",
  del = "<Del>",
  left = "<Left>",
  right = "<Right>",
  up = "<Up>",
}

local open_to_close = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ['"'] = '"',
  ["'"] = "'",
}

local newline_pairs = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
}

local function chars_around_cursor()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local left = col > 0 and line:sub(col, col) or ""
  local right = line:sub(col + 1, col + 1)

  return left, right
end

local function insert_pair(open, close)
  return function()
    return open .. close .. key.left
  end
end

local function insert_or_skip_quote(quote)
  return function()
    local _, right = chars_around_cursor()
    if right == quote then
      return key.right
    end

    return quote .. quote .. key.left
  end
end

local function skip_closing(close)
  return function()
    local _, right = chars_around_cursor()
    if right == close then
      return key.right
    end

    return close
  end
end

local function backspace_empty_pair()
  local left, right = chars_around_cursor()
  if open_to_close[left] == right then
    return key.bs .. key.del
  end

  return key.bs
end

local function blink_accept_or_enter()
  local ok, blink = pcall(require, "blink.cmp")
  if ok and blink.is_visible() then
    if blink.accept() then
      return ""
    end

    return key.cr
  end

  local left, right = chars_around_cursor()
  if newline_pairs[left] == right then
    return key.cr .. key.cr .. key.up
  end

  return key.cr
end

local function apply_buffer_maps(bufnr)
  if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable then
    return
  end

  local opts = { buffer = bufnr, expr = true, silent = true, replace_keycodes = true }
  local function map(lhs, rhs, desc)
    vim.keymap.set("i", lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
  end

  map("(", insert_pair("(", ")"), "Native pairs: insert ()")
  map("[", insert_pair("[", "]"), "Native pairs: insert []")
  map("{", insert_pair("{", "}"), "Native pairs: insert {}")
  map('"', insert_or_skip_quote('"'), 'Native pairs: insert/skip ""')
  map("'", insert_or_skip_quote("'"), "Native pairs: insert/skip ''")

  map(")", skip_closing(")"), "Native pairs: skip )")
  map("]", skip_closing("]"), "Native pairs: skip ]")
  map("}", skip_closing("}"), "Native pairs: skip }")

  map("<BS>", backspace_empty_pair, "Native pairs: delete empty pair")
  map("<CR>", blink_accept_or_enter, "Native pairs: newline inside empty pair")
end

function M.setup()
  local group = vim.api.nvim_create_augroup("nvim_native_autopairs", { clear = true })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    desc = "Apply native pair mappings after completion mappings",
    callback = function(args)
      apply_buffer_maps(args.buf)
    end,
  })

  if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
    apply_buffer_maps(vim.api.nvim_get_current_buf())
  end
end

return M
