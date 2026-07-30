local M = {}

function M.setup()
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
  })
end

return M
