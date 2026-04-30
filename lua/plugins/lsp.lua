return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")
      local blink = require("blink.cmp")

      vim.lsp.config("*", {
        capabilities = blink.get_lsp_capabilities(),
      })

      local servers = { "lua_ls", "clangd", "pyright", "ts_ls" }

      local lsp_keymaps = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = lsp_keymaps,
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local bufnr = event.buf

          if not client then
            return
          end

          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
          end

          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map("<leader>th", function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      -- Neovim 0.12 原生 LSP 配置：先定义 config，再显式 enable。
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("clangd", {
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
        root_markers = {
          ".clangd",
          ".clang-tidy",
          ".clang-format",
          "compile_commands.json",
          "compile_flags.txt",
          "configure.ac",
          "CMakeLists.txt",
          "CMakePresets.json",
          "CMakeUserPresets.json",
          ".git",
        },
      })

      vim.lsp.config("pyright", {
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

      vim.lsp.config("ts_ls", {})

      -- 保留 Mason 管理/安装关系，但让 lsp.lua 的 vim.lsp.enable 成为唯一启用来源。
      mason_lspconfig.setup({
        automatic_enable = false,
      })

      vim.lsp.enable(servers)
    end,
  },
}
