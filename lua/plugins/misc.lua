return {
  -- Git 集成
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup()
    end,
  },
}
