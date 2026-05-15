local shared = require("config.keymaps.shared")
local map = shared.map
local opts = shared.opts
local opts_with_desc = shared.opts_with_desc

local M = {}

local function normal_key(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "nx", false)
end

function M.setup()
  -- 下一个 / 上一个 Buffer
  map("n", "<leader><PageDown>", function()
    _G.nvim_native_buffer_cycle(1)
  end, opts_with_desc("Next buffer"))
  map("n", "<leader><PageUp>", function()
    _G.nvim_native_buffer_cycle(-1)
  end, opts_with_desc("Previous buffer"))

  -- VSCode 风格位置历史：后退 / 前进
  map("n", "<A-Left>", function()
    normal_key("<C-o>")
  end, opts_with_desc("Jump back"))

  map("n", "<A-Right>", function()
    normal_key("<C-i>")
  end, opts_with_desc("Jump forward"))

  -- 快速跳转到指定 Buffer（1~9）
  for i = 1, 9 do
    local index = i
    map("n", "<leader>" .. index, function()
      _G.nvim_native_buffer_goto(index)
    end, opts_with_desc("Go to buffer " .. index))
  end

  -- 分屏操作
  map("n", "<leader><Left>", "<C-w>h", opts) -- 移动到左边窗口
  map("n", "<leader><Down>", "<C-w>j", opts) -- 移动到下边窗口
  map("n", "<leader><Up>", "<C-w>k", opts) -- 移动到上边窗口
  map("n", "<leader><Right>", "<C-w>l", opts) -- 移动到右边窗口

  -- 打开 Neovim 原生 LSP document symbols outline
  map("n", "<leader>o", vim.lsp.buf.document_symbol, opts_with_desc("Document symbols outline"))

  map("n", "<leader>e", ":Neotree toggle<CR>", opts)

  -- 设置显示 / 不显示 tabline
  vim.keymap.set("n", "<leader>tb", function()
    if vim.o.showtabline == 0 then
      vim.o.showtabline = 2
    else
      vim.o.showtabline = 0
    end
  end, { desc = "Toggle native tabline" })
end

return M
