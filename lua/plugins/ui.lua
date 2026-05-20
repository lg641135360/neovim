return {
  -- 语法高亮 & Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    build = ":TSUpdate", -- lazy.nvim 里用 build，不是 run
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)
      require("config.treesitter_compat").setup()
    end,
    opts = {
      ensure_installed = { "c", "cpp", "lua", "python", "cmake" }, -- 必装语言
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = { enable = true },
    },
  },

}
