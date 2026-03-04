return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    require("mason-lspconfig").setup({
      -- 自动安装这些 servers
      ensure_installed = {
        "lua_ls",
        "clangd",
        "pyright",
        "bashls",
        "html",
        "cssls",
        "ts_ls", -- 曾叫 tsserver，现已更名为 ts_ls
        "cmake",
        "texlab",
      },
    })

    require("mason-tool-installer").setup({
      ensure_installed = {
        "stylua", -- Lua formatter
        "black", -- Python formatter
        "isort", -- Python imports sorter
        "prettier", -- Prettier formatter
        "clang-format", -- C/C++ formatter
      },
    })
  end,
}
