return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      { "folke/neodev.nvim", opts = {} },
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")
      local blink = require("blink.cmp")
      local capabilities = blink.get_lsp_capabilities()

      -- 设置 on_attach 和 capabilities 的默认配置
      local original_setup = lspconfig.util.default_config.on_attach
      local original_capabilities = lspconfig.util.default_config.capabilities

      lspconfig.util.default_config.on_attach = function(client, bufnr)
        if original_setup then
          original_setup(client, bufnr)
        end

        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")

        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, "[T]oggle Inlay [H]ints")
        end
      end

      lspconfig.util.default_config.capabilities =
        vim.tbl_deep_extend("force", original_capabilities or {}, capabilities)

      -- 配置特定服务器
      lspconfig.lua_ls.setup({
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      lspconfig.clangd.setup({
        cmd = {
          "clangd",
          "--compile-commands-dir=build",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
      })

      lspconfig.pyright.setup({
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      lspconfig.ts_ls.setup({})

      -- 安装 mason-lspconfig 但禁用 automatic_enable，因为我们手动 setup 了
      mason_lspconfig.setup({
        automatic_enable = false,
      })
    end,
  },
}
