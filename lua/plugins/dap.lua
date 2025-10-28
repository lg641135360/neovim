return {
  -- DAP调试
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true }

      -- ⚡ 断点和当前行图标
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint" })
      vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DapBreakpointCondition" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpointRejected" })

      -- 高亮颜色
      vim.cmd("highlight DapBreakpoint guifg=#FF5555")
      vim.cmd("highlight DapStopped guifg=#50FA7B")
      vim.cmd("highlight DapBreakpointCondition guifg=#F1FA8C")
      vim.cmd("highlight DapBreakpointRejected guifg=#FF79C6")

      -- 🧩 Linux 下使用 lldb 或 codelldb
      dap.adapters.lldb = {
        type = "executable",
        -- ✅ 如果你是自己编译的 lldb（/usr/local/bin/lldb）
        -- command = "/usr/local/bin/lldb",
        -- ⚙️ 如果你用的是 VSCode codelldb 扩展（推荐）
        command = "/usr/local/bin/lldb-dap",
        name = "lldb",
      }

      -- 🧠 自动检测可执行文件
      local function get_default_executable()
        local cwd = vim.fn.getcwd()
        local build = cwd .. "/build"
        local bin_dir = build .. "/bin"

        -- 查找 build/bin 或 build 下的 ELF 文件
        local exe_candidates = vim.fn.glob(bin_dir .. "/*", false, true)
        if #exe_candidates == 0 then
          exe_candidates = vim.fn.glob(build .. "/*", false, true)
        end

        -- 过滤掉非可执行文件
        local executables = {}
        for _, f in ipairs(exe_candidates) do
          if vim.fn.executable(f) == 1 then
            table.insert(executables, f)
          end
        end

        if #executables > 0 then
          return vim.fn.input("Path to executable: ", executables[1], "file")
        end

        return vim.fn.input("Path to executable: ", cwd .. "/", "file")
      end

      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "lldb",
          request = "launch",
          program = get_default_executable,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- 快捷键
      map("n", "<F5>", dap.continue, opts)
      map("n", "<F10>", dap.step_over, opts)
      map("n", "<F11>", dap.step_into, opts)
      map("n", "<F12>", dap.step_out, opts)
      map("n", "<leader>b", dap.toggle_breakpoint, opts)
      map("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, opts)
      map("n", "<leader>dr", dap.repl.open, opts)
      map("n", "<leader>dl", dap.run_last, opts)
      map("n", "<leader>du", function()
        require("dapui").toggle()
      end, opts)
    end,
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      local dapui = require("dapui")
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸" },
        layouts = {
          {
            elements = { "scopes", "breakpoints", "stacks", "watches" },
            size = 40,
            position = "right",
          },
          {
            elements = { "repl", "console" },
            size = 10,
            position = "bottom",
          },
        },
        floating = {
          max_height = 0.9,
          max_width = 0.5,
          border = "rounded",
          mappings = { close = { "q", "<Esc>" } },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            terminate = "■",
          },
        },
      })

      -- 自动打开/关闭 dapui
      local dap = require("dap")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- 异步支持
  {
    "nvim-neotest/nvim-nio",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
