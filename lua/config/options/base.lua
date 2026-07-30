local M = {}

function M.setup()
  vim.opt.number = true
  vim.opt.relativenumber = false
  vim.opt.expandtab = true
  vim.opt.shiftwidth = 2
  vim.opt.tabstop = 2
  vim.opt.smartindent = true
  vim.opt.termguicolors = true
  vim.opt.swapfile = false
  vim.opt.mouse = "a"

  vim.opt.cursorline = true -- 开启光标行高亮（可以只高亮行号）
  vim.opt.cursorlineopt = "number" -- 只高亮行号，而不是整行

  vim.o.modeline = false

  -- 添加 '-' 词语
  vim.opt.iskeyword:append("-")

  -- 使得左右键可以跨行
  vim.opt.whichwrap:append("<>,h,l")

  -- 禁止加载 netrw 核心
  vim.g.loaded_netrw = 1

  -- 禁止加载 netrw 的 plugin 层
  vim.g.loaded_netrwPlugin = 1

  -- use system clipboard
  vim.opt.clipboard = "unnamedplus"
end

return M
