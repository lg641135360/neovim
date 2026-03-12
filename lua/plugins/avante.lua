return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  opts = {
    provider = "claude",
    providers = {
      claude = {
        __inherited_from = "openai",
        api_key_name = "ANTHROPIC_API_KEY",
        endpoint = "https://api.anthropic.com/v1",
        model = "claude-sonnet-4-20250514",
        -- 可选：使用更高智能的模型
        -- model = "claude-opus-4-20250514",
      },
    },
    auto_suggestions_provider = "claude",
    behaviour = {
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = true,
    },
    mappings = {
      ask = "<leader>aa",
      edit = "<leader>ae",
      refresh = "<leader>ar",
      toggle = {
        default = "<leader>at",
        focus = "<leader>af",
      },
      jump = {
        next = "<leader>aj",
        prev = "<leader>ak",
      },
    },
    windows = {
      position = "right",
      wrap = true,
      width = 40,
      sidebar_header = {
        enabled = true,
        align = "center",
      },
    },
    highlights = {
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
  build = "make",
}
