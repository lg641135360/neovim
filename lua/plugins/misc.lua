return {
  -- Git 集成
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- 自动括号匹配
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({
        check_ts = true, -- 启用 Treesitter 检测语言
        enable_check_bracket_line = true, -- 同一行避免重复括号
      })

      -- -- 集成 nvim-cmp
      -- local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      -- local cmp = require("cmp")
      -- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Neovim 0.12 内置了 gc/gcc 注释映射，不再让 Comment.nvim 覆盖它。
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        mappings = false,
      })
    end,
  },
}
