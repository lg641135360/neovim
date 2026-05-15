local function normalize_directory(dir)
  if not dir or dir == "" then
    return nil
  end

  local expanded = vim.fn.fnamemodify(vim.fn.expand(dir), ":p")
  return vim.fs.normalize(expanded)
end

local function current_search_directory()
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= "" then
    return vim.fs.dirname(name)
  end

  return vim.fn.getcwd()
end

local function split_csv_patterns(input)
  if not input or vim.trim(input) == "" then
    return {}
  end

  local items = {}
  for _, part in ipairs(vim.split(input, ",", { trimempty = true })) do
    local trimmed = vim.trim(part)
    if trimmed ~= "" then
      items[#items + 1] = trimmed
    end
  end
  return items
end

local function split_whitespace_args(input)
  if not input or vim.trim(input) == "" then
    return {}
  end

  return vim.split(vim.trim(input), "%s+", { trimempty = true })
end

local function grep_in_directory(dir)
  local target = normalize_directory(dir)
  if not target or vim.fn.isdirectory(target) == 0 then
    vim.notify(("Directory not found: %s"):format(tostring(dir)), vim.log.levels.WARN)
    return
  end

  Snacks.picker.grep({ dirs = { target } })
end

local function grep_current_file_directory()
  grep_in_directory(current_search_directory())
end

local function grep_prompt_directory()
  vim.ui.input({
    prompt = "Grep directory: ",
    default = current_search_directory(),
    completion = "dir",
  }, function(input)
    if not input or input == "" then
      return
    end

    grep_in_directory(input)
  end)
end

local function grep_with_constraints()
  local modes = {
    {
      key = "regex",
      label = "Regex",
      regex = true,
      args = {},
    },
    {
      key = "fixed",
      label = "Fixed string",
      regex = false,
      args = {},
    },
    {
      key = "word",
      label = "Whole word",
      regex = false,
      args = { "--word-regexp" },
    },
  }

  vim.ui.select(modes, {
    prompt = "Grep mode:",
    format_item = function(item)
      return item.label
    end,
  }, function(mode)
    if not mode then
      return
    end

    vim.ui.input({
      prompt = "Include globs (,): ",
    }, function(include_input)
      if include_input == nil then
        return
      end

      vim.ui.input({
        prompt = "Exclude globs (,): ",
      }, function(exclude_input)
        if exclude_input == nil then
          return
        end

        vim.ui.input({
          prompt = "Extra rg args: ",
          default = "",
        }, function(extra_args_input)
          if extra_args_input == nil then
            return
          end

          local opts = {
            regex = mode.regex,
            args = vim.deepcopy(mode.args),
          }

          local include_patterns = split_csv_patterns(include_input)
          if #include_patterns > 0 then
            opts.glob = include_patterns
          end

          local exclude_patterns = split_csv_patterns(exclude_input)
          if #exclude_patterns > 0 then
            opts.exclude = exclude_patterns
          end

          vim.list_extend(opts.args, split_whitespace_args(extra_args_input))
          Snacks.picker.grep(opts)
        end)
      end)
    end)
  end)
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    indent = {
      enabled = true,

      -- 背景灰色普通缩进线
      indent = {
        priority = 1,
        enabled = true, -- enable indent guides
        char = "│",
        only_scope = false, -- only show indent guides of the scope
        only_current = false, -- only show indent guides in the current window
      },

      -- 当前所在代码块
      scope = {
        enabled = true, -- enable highlighting the current scope
        priority = 200,
        char = "│",
        underline = false, -- underline the start of the scope
        only_current = false, -- only show scope in the current window
        hl = "SnacksIndentScope", ---@type string|string[] hl group for scopes
      },
    },

    -- 替代telescope
    picker = {
      enabled = true,
      win = {
        input = {
          keys = {
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            ["<Tab>"] = { "list_down", mode = { "i", "n" } },
          },
        },

        list = {
          keys = {
            ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            ["<Tab>"] = { "list_down", mode = { "i", "n" } },
          },
        },
      },
    },

    notifier = {
      enabled = true,
      timeout = 8000,
      width = { min = 50, max = 0.7 },
      height = { min = 1, max = 0.8 },
    },

    styles = {
      notification = {
        wo = {
          wrap = true,
        },
      },
      notification_history = {
        width = 0.8,
        height = 0.8,
      },
    },

    scope = { enabled = true },
    dashboard = { enabled = false },
    input = { enabled = true },
    animate = {},
  },

  keys = {
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffers",
    },
    {
      "<leader>ff",
      function()
        Snacks.picker.files({ hidden = true, ignored = false })
      end,
      desc = "Find Files",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.grep()
      end,
      desc = "Find Grep",
    },
    {
      "<leader>fG",
      grep_with_constraints,
      desc = "Find Grep with constraints",
    },
    {
      "<leader>fD",
      grep_current_file_directory,
      desc = "Find Grep in current file directory",
    },
    {
      "<leader>fd",
      grep_prompt_directory,
      desc = "Find Grep in directory",
    },
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Grep word or selection",
      mode = { "n", "x" },
    },
    {
      "<leader>fp",
      function()
        Snacks.picker.projects()
      end,
      desc = "Projects",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent",
    },
    {
      "<leader>:",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.search_history()
      end,
      desc = "Search History",
    },

    {
      "<leader>sd",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "Diagnostics",
    },

    {
      "gd",
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = "Goto Definition",
    },
    {
      "gD",
      function()
        Snacks.picker.lsp_declarations()
      end,
      desc = "Goto Declaration",
    },
    {
      "grr",
      function()
        Snacks.picker.lsp_references()
      end,
      desc = "References",
    },
    {
      "gI",
      function()
        Snacks.picker.lsp_implementations()
      end,
      desc = "Goto Implementation",
    },
    {
      "gy",
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      desc = "Goto T[y]pe Definition",
    },
    {
      "<leader>gs",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Git Status",
    },
    {
      "<leader>gd",
      function()
        Snacks.picker.git_diff()
      end,
      desc = "Git Diff (Hunks)",
    },

    {
      "gai",
      function()
        Snacks.picker.lsp_incoming_calls()
      end,
      desc = "C[a]lls Incoming",
    },
    {
      "gao",
      function()
        Snacks.picker.lsp_outgoing_calls()
      end,
      desc = "C[a]lls Outgoing",
    },
    {
      "<leader>ss",
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = "LSP Symbols",
    },
    {
      "<leader>sS",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "LSP Workspace Symbols",
    },

    {
      "<leader>nh",
      function()
        Snacks.picker.notifications()
      end,
      desc = "Notification History",
    },
  },
}
