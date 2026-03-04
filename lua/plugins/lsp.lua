return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      { "folke/neodev.nvim", opts = {} }, -- 为 LSP 提供 Neovim Lua 开发环境
    },
    config = function()
      local lspconfig = require("lspconfig")
      local blink = require("blink.cmp")
      local capabilities = blink.get_lsp_capabilities()

      local on_attach = function(client, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
        end

        -- ❌ 移除了所有 Telescope 相关的绑定 (gd, gr, gI, etc.)
        -- ✅ 这些功能现在由 snacks.lua 中的 pickers 接管

        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        -- map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration") -- Snacks 也有这个绑定

        -- 客户端特定配置
        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, "[T]oggle Inlay [H]ints")
        end
      end

      -- 通用 Handler
      local setup_server = function(server_name, config)
        config = config or {}
        config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {})
        config.on_attach = on_attach
        lspconfig[server_name].setup(config)
      end

      -- Mason 自动设置所有服务器
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          setup_server(server_name)
        end,
        ["lua_ls"] = function()
          setup_server("lua_ls", {
            settings = {
              Lua = {
                completion = { callSnippet = "Replace" },
                workspace = { checkThirdParty = false },
                telemetry = { enable = false },
              },
            },
          })
        end,
        ["clangd"] = function()
          setup_server("clangd", {
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm",
            },
          })
        end,
        ["pyright"] = function()
          setup_server("pyright", {
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
        end,
        -- 移除 tsserver，改用 ts_ls
        ["ts_ls"] = function()
          setup_server("ts_ls")
        end,
      })
    end,
  },
}
