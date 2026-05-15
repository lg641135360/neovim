local M = {}

local mode_labels = {
  n = "NORMAL",
  no = "OP-PENDING",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  c = "COMMAND",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
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

function M.setup()
  vim.opt.laststatus = 3
  vim.opt.winborder = "rounded"
  vim.opt.pumborder = "rounded"

  vim.opt.statusline = "%!v:lua.nvim_native_statusline()"
  vim.opt.showtabline = 2
  vim.opt.tabline = "%!v:lua.nvim_native_tabline()"
end

return M
