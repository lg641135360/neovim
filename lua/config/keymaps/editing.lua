local shared = require("config.keymaps.shared")
local map = shared.map
local opts = shared.opts
local opts_with_desc = shared.opts_with_desc

local M = {}

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

function M.setup()
  -- 当前文件格式化
  map("n", "<leader>fm", function()
    require("conform").format({
      async = true,
      lsp_fallback = true,
    })
  end, opts_with_desc("Format buffer"))

  -- 可选：兼容终端中使用 Ctrl+C（仅在 GUI 中安全，终端中慎用）
  map("v", "<C-c>", [["+y]], opts)
  map("n", "<C-c>", [["+yy]], opts)

  -- 剪切到系统剪贴板
  map("v", "<C-x>", [["+d]], opts) -- 可视模式剪切
  map("n", "<C-x>", [["+dd]], opts) -- 普通模式剪切整行

  -- 黏贴到当前光标位置
  map("n", "<C-v>", [["+p]], opts)
  map("v", "<C-v>", [["+p]], opts)

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

  -- Visual 模式下缩进
  map("v", "<Tab>", ">", opts)
  map("v", "<S-Tab>", "<", opts) -- Shift+Tab 减少缩进

  -- 普通模式下全选
  map("n", "<C-a>", "gg0vG$", opts)
end

return M
