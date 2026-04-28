local function is_headless()
  for _, arg in ipairs(vim.v.argv or {}) do
    if arg == "--headless" then
      return true
    end
  end
  return false
end

return {
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = function()
      return {
        ensure_installed = {
          "stylua",
          "black",
          "isort",
          "prettier",
          "clang-format",
          "jq",
          "shfmt",
          "tex-fmt",
        },
        -- 正常打开 Neovim 时自动补齐工具；headless 测试/脚本启动时避免触发安装。
        run_on_start = not is_headless(),
        start_delay = 3000,
      }
    end,
  },
}
