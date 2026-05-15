local shared = require("config.keymaps.shared")
local map = shared.map
local opts = shared.opts
local opts_with_desc = shared.opts_with_desc

local M = {}

local function is_empty_unnamed_buffer(bufnr)
  if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].modified then
    return false
  end

  if vim.api.nvim_buf_get_name(bufnr) ~= "" then
    return false
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return #lines == 1 and lines[1] == ""
end

local function close_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  if is_empty_unnamed_buffer(bufnr) then
    vim.cmd.quit()
    return
  end

  local ok, err = pcall(vim.cmd.bdelete)
  if not ok then
    vim.notify(tostring(err), vim.log.levels.WARN)
  end
end

local function register_safe_quit_behavior()
  vim.api.nvim_create_user_command("BufferClose", close_current_buffer, {
    desc = "Close current buffer without quitting Neovim",
    force = true,
  })

  vim.cmd([[
cnoreabbrev <expr> q getcmdtype() ==# ':' && getcmdline() =~# '^\s*q\s*$' ? 'BufferClose' : 'q'
cnoreabbrev <expr> quit getcmdtype() ==# ':' && getcmdline() =~# '^\s*quit\s*$' ? 'BufferClose' : 'quit'
]])
end

function M.setup()
  -- 强制关闭当前 Buffer
  map("n", "<leader>c", ":bdelete!<CR>", opts)

  -- 文件操作
  map("n", "<leader>w", ":w<CR>", opts) -- 保存
  map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR>", opts_with_desc("Save file")) -- 快速保存

  register_safe_quit_behavior()
  map("n", "<leader>q", close_current_buffer, opts_with_desc("Close current buffer")) -- 关闭当前文件，不退出 Neovim

  -- 在终端模式中按 Esc 直接退出到普通模式
  map("t", "<Esc>", [[<C-\><C-n>]], opts)

  -- 打开一个浮动终端
  local float_term = require("customs.float_trem")
  map("n", "<leader>ft", float_term.open, opts)

  -- 打开原生 diagnostics quickfix 列表
  map("n", "<leader>xx", function()
    vim.diagnostic.setqflist({ open = true })
  end, opts_with_desc("Diagnostics quickfix"))

  map("n", "<leader>df", function()
    vim.diagnostic.open_float(0, {
      scope = "line",
      focus = false,
    })
  end, opts_with_desc("Diagnostic float"))

  map("n", "<leader>dj", function()
    vim.diagnostic.jump({
      count = 1,
      float = true,
    })
  end, opts_with_desc("Next diagnostic"))

  map("n", "<leader>dk", function()
    vim.diagnostic.jump({
      count = -1,
      float = true,
    })
  end, opts_with_desc("Previous diagnostic"))
end

return M
