local active_theme = "catppuccin-mocha"

local themes = {
  ["catppuccin-mocha"] = {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
      })
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
}

return { themes[active_theme] }
