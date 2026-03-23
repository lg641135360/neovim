return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        json = { "jq" },
        jsonc = { "prettier" },
        sh = { "shfmt" },
        c = { "clang-format" }, -- 添加 C 语言
        cc = { "clang-format" },
        cpp = { "clang-format" }, -- 如果写 C++ 也用 clang-format
        html = { "prettier" }, -- 添加 HTML 格式化工具
        css = { "prettier" }, -- 添加 CSS 格式化工具
        tex = { "tex-fmt" },
      },
    },
  },
}
