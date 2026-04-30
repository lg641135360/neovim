-- 自定义快捷键。
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

local function opts_with_desc(desc)
  return vim.tbl_extend("force", opts, { desc = desc })
end

-- leader 键
vim.g.mapleader = " " -- 空格为 leader

-- 下一个 / 上一个 Tab
map("n", "<leader><PageDown>", function()
  _G.nvim_native_buffer_cycle(1)
end, opts_with_desc("Next buffer"))
map("n", "<leader><PageUp>", function()
  _G.nvim_native_buffer_cycle(-1)
end, opts_with_desc("Previous buffer"))

-- 快速跳转到指定 Tab（1~9）
for i = 1, 9 do
  local index = i
  map("n", "<leader>" .. index, function()
    _G.nvim_native_buffer_goto(index)
  end, opts_with_desc("Go to buffer " .. index))
end

-- 关闭当前 Tab
map("n", "<leader>c", ":bdelete!<CR>", opts)

-- 分屏操作
map("n", "<leader><Left>", "<C-w>h", opts) -- 移动到左边窗口
map("n", "<leader><Down>", "<C-w>j", opts) -- 移动到下边窗口
map("n", "<leader><Up>", "<C-w>k", opts) -- 移动到上边窗口
map("n", "<leader><Right>", "<C-w>l", opts) -- 移动到右边窗口

-- 文件操作
map("n", "<leader>w", ":w<CR>", opts) -- 保存
map({ "n", "i", "v" }, "<C-s>", "<cmd>write<CR>", opts_with_desc("Save file")) -- 快速保存
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

map("n", "<leader>q", close_current_buffer, opts_with_desc("Close current buffer")) -- 关闭当前文件，不退出 Neovim

-- 在终端模式中按 Esc 直接退出到普通模式
map("t", "<Esc>", [[<C-\><C-n>]], opts)

-- 可选：兼容终端中使用 Ctrl+C（仅在 GUI 中安全，终端中慎用）
map("v", "<C-c>", [["+y]], opts)
map("n", "<C-c>", [["+yy]], opts)

-- 剪切到系统剪贴板
map("v", "<C-x>", [["+d]], opts) -- 可视模式剪切
map("n", "<C-x>", [["+dd]], opts) -- 普通模式剪切整行

-- 黏贴到当前光标位置
map("n", "<C-v>", [["+p]], opts)
map("v", "<C-v>", [["+p]], opts)

local function sorted_line_range(start_line, end_line)
  if start_line > end_line then
    return end_line, start_line
  end
  return start_line, end_line
end

local function get_visual_line_range()
  return sorted_line_range(vim.fn.line("v"), vim.fn.line("."))
end

local function move_line_range(start_line, end_line, direction)
  start_line, end_line = sorted_line_range(start_line, end_line)

  local line_count = vim.api.nvim_buf_line_count(0)
  if direction < 0 and start_line <= 1 then
    vim.api.nvim_win_set_cursor(0, { start_line, 0 })
    return
  end
  if direction > 0 and end_line >= line_count then
    vim.api.nvim_win_set_cursor(0, { end_line, 0 })
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {})

  local insert_at = direction < 0 and start_line - 2 or start_line
  vim.api.nvim_buf_set_lines(0, insert_at, insert_at, false, lines)
  vim.api.nvim_win_set_cursor(0, { start_line + direction, 0 })
end

local function copy_line_range(start_line, end_line, direction)
  start_line, end_line = sorted_line_range(start_line, end_line)

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local insert_at = direction < 0 and start_line - 1 or end_line
  vim.api.nvim_buf_set_lines(0, insert_at, insert_at, false, lines)

  local copied_start = direction < 0 and start_line or end_line + 1
  vim.api.nvim_win_set_cursor(0, { copied_start, 0 })
end

map("n", "<A-Up>", function()
  local line = vim.fn.line(".")
  move_line_range(line, line, -1)
end, opts_with_desc("Move current line up"))

map("n", "<A-Down>", function()
  local line = vim.fn.line(".")
  move_line_range(line, line, 1)
end, opts_with_desc("Move current line down"))

map("x", "<A-Up>", function()
  local start_line, end_line = get_visual_line_range()
  move_line_range(start_line, end_line, -1)
end, opts_with_desc("Move selected lines up"))

map("x", "<A-Down>", function()
  local start_line, end_line = get_visual_line_range()
  move_line_range(start_line, end_line, 1)
end, opts_with_desc("Move selected lines down"))

map("n", "<S-A-Up>", function()
  local line = vim.fn.line(".")
  copy_line_range(line, line, -1)
end, opts_with_desc("Copy current line up"))

map("n", "<S-A-Down>", function()
  local line = vim.fn.line(".")
  copy_line_range(line, line, 1)
end, opts_with_desc("Copy current line down"))

map("x", "<S-A-Up>", function()
  local start_line, end_line = get_visual_line_range()
  copy_line_range(start_line, end_line, -1)
end, opts_with_desc("Copy selected lines up"))

map("x", "<S-A-Down>", function()
  local start_line, end_line = get_visual_line_range()
  copy_line_range(start_line, end_line, 1)
end, opts_with_desc("Copy selected lines down"))

-- 文本选择与跳转
map("n", "vv", "v%", opts)
map("n", "vc", "viw", opts)
map("n", "vl", "V", opts)

-- 清除查找高亮
map("n", "<Esc>", "<cmd>nohlsearch<CR>", opts)

-- 打开一个浮动终端
local float_term = require("customs.float_trem")
map("n", "<leader>ft", float_term.open, opts)

-- 打开原生 diagnostics quickfix 列表
map("n", "<leader>xx", function()
  vim.diagnostic.setqflist({ open = true })
end, opts_with_desc("Diagnostics quickfix"))

-- 打开 Neovim 原生 LSP document symbols outline
map("n", "<leader>o", vim.lsp.buf.document_symbol, opts_with_desc("Document symbols outline"))

-- 在你的 keymaps.lua 中添加
map("v", "<Tab>", ">", opts)
map("v", "<S-Tab>", "<", opts) -- Shift+Tab 减少缩进

map("n", "<leader>e", ":Neotree toggle<CR>", opts)

-- 设置显示 / 不显示 tab
vim.keymap.set("n", "<leader>tb", function()
  if vim.o.showtabline == 0 then
    vim.o.showtabline = 2
  else
    vim.o.showtabline = 0
  end
end, { desc = "Toggle native tabline" })

-- 普通模式下全选
map("n", "<C-a>", "gg0vG$", opts)
