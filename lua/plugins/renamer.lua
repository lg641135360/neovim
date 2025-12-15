return {
  "filipdutescu/renamer.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local ok, renamer = pcall(require, "renamer")
    if not ok then
      return
    end

    renamer.setup({
      -- 避免动态宽度导致 popup cursor 越界
      popup = {
        border = "rounded",
        padding = { top = 1, bottom = 1, left = 1, right = 1 },
        width = 35, -- 固定宽度避免 cursor 溢出
        height = 1,
      },

      -- 禁用破坏性的 cursor 修正逻辑（bug 所在）
      on_show_popup = function(bufnr, winid)
        -- 手动将光标设置到行尾（避免列越界）
        vim.api.nvim_win_set_cursor(winid, { 1, 0 })
      end,

      -- 不使用 popup 自动定位，自己控制（避免越界）
      show_popup = true,
    })

    -- 绑定 rename 快捷键
    vim.keymap.set("n", "<leader>rn", function()
      renamer.rename()
    end, { desc = "Rename (LSP)" })
  end,
}
