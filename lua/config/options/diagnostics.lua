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
    -- underline = true, -- 保留下划线标记
    -- update_in_insert = false, -- 插入模式不更新（可选）
  })
end

return M
