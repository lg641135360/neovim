-- 基础编辑选项在 lazy.nvim 启动前加载。

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.mouse = "a"
vim.opt.laststatus = 3
vim.opt.winborder = "rounded"
vim.opt.pumborder = "rounded"

local mode_labels = {
  n = "NORMAL",
  no = "OP-PENDING",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  [""] = "V-BLOCK",
  c = "COMMAND",
  s = "SELECT",
  S = "S-LINE",
  ["9"] = "S-BLOCK",
  R = "REPLACE",
  t = "TERMINAL",
}

local function statusline_diagnostics()
  local counts = vim.diagnostic.count(0)
  local severity = vim.diagnostic.severity
  local items = {
    "E:" .. tostring(counts[severity.ERROR] or 0),
    "W:" .. tostring(counts[severity.WARN] or 0),
    "I:" .. tostring(counts[severity.INFO] or 0),
    "H:" .. tostring(counts[severity.HINT] or 0),
  }
  return table.concat(items, " ")
end

function _G.nvim_native_statusline()
  local mode = mode_labels[vim.api.nvim_get_mode().mode] or vim.api.nvim_get_mode().mode:upper()
  local filetype = vim.bo.filetype ~= "" and vim.bo.filetype or "noft"
  return table.concat({
    " ",
    mode,
    " %t%m%r",
    "%=",
    statusline_diagnostics(),
    " ",
    filetype,
    " %p%% %l:%c ",
  })
end

vim.opt.statusline = "%!v:lua.nvim_native_statusline()"

local function native_listed_buffers()
  local buffers = {}
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if vim.bo[info.bufnr].buftype == "" then
      table.insert(buffers, info.bufnr)
    end
  end
  if #buffers == 0 then
    table.insert(buffers, vim.api.nvim_get_current_buf())
  end
  return buffers
end

function _G.nvim_native_buffer_goto(index)
  local bufnr = native_listed_buffers()[index]
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_set_current_buf(bufnr)
  end
end

function _G.nvim_native_buffer_cycle(direction)
  vim.cmd(direction > 0 and "bnext" or "bprevious")
end

function _G.nvim_native_tabline()
  local current = vim.api.nvim_get_current_buf()
  local parts = {}
  for index, bufnr in ipairs(native_listed_buffers()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    local label = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"
    local modified = vim.bo[bufnr].modified and "●" or ""
    local highlight = bufnr == current and "%#TabLineSel#" or "%#TabLine#"
    table.insert(parts, ("%s%%%dT %d:%s%s %%T"):format(highlight, bufnr, index, label, modified))
  end
  table.insert(parts, "%#TabLineFill#%T")
  return table.concat(parts, "")
end

vim.opt.showtabline = 2
vim.opt.tabline = "%!v:lua.nvim_native_tabline()"

-- 禁止自动注释续行
vim.opt.formatoptions:remove({ "c", "r", "o" })

vim.opt.cursorline = true -- 开启光标行高亮（可以只高亮行号）
vim.opt.cursorlineopt = "number" -- 只高亮行号，而不是整行

-- 全局 LSP 诊断配置
vim.diagnostic.config({
  signs = false, -- ❌ 左侧 gutter 不显示 E/W
  virtual_text = {
    source = "if_many",
    spacing = 2,
    prefix = "●",
    virt_text_pos = "inline",
  },
  virtual_lines = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
  },
  -- underline = true, -- 保留下划线标记
  -- update_in_insert = false, -- 插入模式不更新（可选）
})

-- 创建 :H 命令，在新 tab 中打开帮助
vim.api.nvim_create_user_command("Hv", function(opts)
  vim.cmd("vertical help " .. (opts.args ~= "" and opts.args or ""))
end, { nargs = "*", complete = "help" })

vim.o.modeline = false

-- 添加 '-' 词语
vim.opt.iskeyword:append("-")

-- 使得左右键可以跨行
vim.o.whichwrap = vim.o.whichwrap .. "<>,h,l"

-- 禁止加载 netrw 核心
vim.g.loaded_netrw = 1

-- 禁止加载 netrw 的 plugin 层
vim.g.loaded_netrwPlugin = 1

-- use system clipboard
vim.opt.clipboard = "unnamedplus"
