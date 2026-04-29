# Neovim Configuration

> 🧠 A modern, fast, and opinionated Neovim setup  
> 基于 **LSP + blink-cmp + snacks.nvim** 的现代化 Neovim 个人配置

---

## ✨ Features | 特性

- 🚀 **Plugin management** – 使用 `lazy.nvim` 管理插件；核心 UX 插件多为 eager，以稳定日常 UX，个别插件通过 `event` / `cmd` / `ft` / `keys` 延迟加载
- 🧩 **LSP-centric** – 以原生 LSP 为核心，而非 IDE 模拟
- ⚡ **blink-cmp** – 极速、简洁的补全体验
- 🍿 **snacks.nvim** – Picker / UI / Notifier / input 一体化方案
- 🧭 **Neovim 0.12 defaults** – 优先使用内置 `gc/gcc` 注释、LSP 默认能力与原生 cmdline/messages
- ⌨️ **Documented keymaps** – 用户可感知快捷键改动必须同步记录
- 🎨 **Clean UI** – Catppuccin Mocha，克制、低噪音、可读性优先
- 🛠 **Highly modular** – 插件按功能拆分，易维护

---

## 🧱 Core Architecture | 核心架构

### 🔹 LSP (Language Server Protocol)

- 使用 **Neovim 内置 LSP**，配置主线对齐 0.12 `vim.lsp.config()` / `vim.lsp.enable()`
- `mason.nvim` 负责 LSP 工具链入口，`mason-tool-installer.nvim` 负责常用 formatter 工具补齐
- `nvim-lspconfig` 保留为 server config 数据来源，不再使用旧的 `lspconfig.SERVER.setup()` 主线
- `lsp.lua` 统一配置：
  - `blink.cmp` LSP capabilities
  - LSP buffer-local alias keymaps
  - inlay hints
  - server-specific settings
  - `lua_ls` 显式声明 Neovim LuaJIT runtime、`vim` global 与 runtime `workspace.library`，不再依赖旧 `neodev.nvim` hook
- 启用的 server：`lua_ls`、`clangd`、`pyright`、`ts_ls`
- Mason 工具自动安装仅在交互式 Neovim 启动时运行；headless 测试 / 脚本启动会跳过自动安装，避免网络和写入副作用

> 目标：**让编辑器理解代码，而不是堆插件**

---

### 🔹 Neovim 0.12 defaults

- 注释优先使用 Neovim 内置 `gc` / `gcc`。
- LSP 默认键位包括 `grn`、`gra`、`grr`、`gri`、`grt`、`grx`、`gO`。
- 当前保留旧 alias：`<leader>rn`、`<leader>ca`、`K`。
- `grr` 使用 `snacks.nvim` references picker，对齐 Neovim 0.12 references 默认语义。
- `<leader>rn` 现在只作为 LSP buffer-local rename alias，和 `grn` 一起调用 Neovim 原生 rename。
- 浮窗与补全菜单默认使用 0.12 `winborder` / `pumborder` 统一为 `rounded`；诊断浮窗同样使用 rounded border，并只在多来源时显示 source。
- Noice 已由 Neovim 原生 cmdline/messages + 0.12 border defaults 替代；通知与输入类 UI 继续由 `snacks.nvim` notifier / input 承担。
- 状态栏使用 Neovim 原生 `statusline` + `laststatus=3`，显示 mode、文件名、modified/readonly、diagnostic counts、filetype 与位置。
- 诊断行内提示使用 Neovim 原生 `virtual_text` + `virt_text_pos = "inline"`，避免额外诊断显示插件；diagnostic signs 关闭，`virtual_lines` 关闭。

---

### 🔹 Editing keymaps

| 快捷键 | 模式 | 行为 |
|--------|------|------|
| `<A-Up>` / `<A-Down>` | Normal | 移动当前行上 / 下 |
| `<A-Up>` / `<A-Down>` | Visual | 移动选中的多行上 / 下 |
| `<S-A-Up>` / `<S-A-Down>` | Normal | 复制当前行到上方 / 下方 |
| `<S-A-Up>` / `<S-A-Down>` | Visual | 复制选中的多行到上方 / 下方 |

- 行移动与复制使用本地 Lua buffer 操作，不依赖额外插件，也不通过默认寄存器实现。
- 终端必须能把这些组合键传给 Neovim；当前仓库的 Alacritty Linux / macOS profile 已显式发送对应 xterm modifier 序列。

### 🔹 Daily keymaps

| 快捷键 | 行为 |
|--------|------|
| `<leader><PageDown>` / `<leader><PageUp>` | BufferLine 下一个 / 上一个 buffer |
| `<leader>1` ... `<leader>9` | 跳到对应序号 buffer |
| `<leader>c` | 强制删除当前 buffer |
| `<leader>tb` | 显示 / 隐藏 bufferline |
| `<leader><Left/Down/Up/Right>` | 在窗口间按方向移动 |
| `<leader>w` / `<leader>q` | 保存 / 关闭窗口 |
| `<leader>e` | 切换 Neo-tree |
| `<leader>ft` | 打开自定义浮动终端 |
| `<leader>xx` | 打开 Neovim 原生 diagnostics quickfix |
| `<leader>o` | 打开 Neovim 原生 LSP document symbols outline（同类默认入口：`gO`） |
| `<leader>th` | LSP buffer 内切换 inlay hints（server 支持时） |
| `<Esc>` | 普通模式清除搜索高亮；终端模式回到普通模式 |
| `<C-a>` | 普通模式全选 |
| `<C-c>` / `<C-x>` / `<C-v>` | 使用系统剪贴板复制 / 剪切 / 粘贴 |
| `vv` / `vc` / `vl` | 选择匹配块 / 当前词 / 当前行 |
| Visual `<Tab>` / `<S-Tab>` | 增加 / 减少缩进 |

---

### 🔹 Completion – blink-cmp

- 使用 [`blink-cmp`](https://github.com/Saghen/blink.cmp)
- 替代传统 `nvim-cmp`
- 特点：
  - 更快
  - 更少魔法
  - 更清晰的 source 管理
- 默认 sources：`lsp`、`path`、`snippets`、`buffer`
- 关键键位：
  - `<Tab>` / `<S-Tab>`：补全菜单中选择下一项 / 上一项，或跳转 snippet 占位符
  - `<CR>`：接受当前补全项
  - `<C-space>`：显示补全和文档
  - `<C-k>`：显示 / 隐藏 signature help

配置文件：
`lua/plugins/blink-cmp.lua`

---

### 🔹 UI / Picker – snacks.nvim

- 使用 [`folke/snacks.nvim`](https://github.com/folke/snacks.nvim)
- 替代：
  - telescope
  - notify
  - 部分 UI 插件
- Noice 移除后，snacks.nvim 继续提供 Notifier / input；命令行与 messages 回到 Neovim 原生实现。

主要功能：
- Picker（文件 / LSP / Git）
- Notifier
- Indent / UI enhancements
- Dashboard / input / scope

常用入口：

| 快捷键 | 行为 |
|--------|------|
| `<leader>ff` / `<leader>fg` | 查找文件 / grep |
| `<leader>fb` / `<leader>fr` / `<leader>fp` | buffers / recent / projects |
| `<leader>:` / `<leader>/` | command history / search history |
| `<leader>sd` | diagnostics |
| `gd` / `gD` / `grr` / `gI` / `gy` | definitions / declarations / references / implementations / type definitions |
| `gai` / `gao` | incoming / outgoing calls |
| `<leader>ss` / `<leader>sS` | document symbols / workspace symbols |
| `<leader>gs` / `<leader>gd` | git status / git diff hunks |
| `<leader>nh` | notification history |

配置文件：
`lua/plugins/snacks.lua`

---

### 🔹 Tools / Formatting

- `mason-tool-installer.nvim` 在非 headless 启动时延迟安装：`stylua`、`black`、`isort`、`prettier`、`clang-format`、`jq`、`shfmt`、`tex-fmt`。
- `conform.nvim` 负责 formatter 映射：
  - Lua: `stylua`
  - Python: `black`
  - JavaScript / TypeScript / JSONC / HTML / CSS: `prettier`
  - JSON: `jq`
  - Shell: `shfmt`
  - C / C++: `clang-format`
  - TeX: `tex-fmt`
- DAP 当前未启用；`lua/plugins/dap.lua` 保留为空配置占位。
- `<leader>xx` 使用 Neovim 原生 `vim.diagnostic.setqflist({ open = true })` 打开 diagnostics quickfix；`<leader>sd` 仍保留 snacks diagnostics picker。

---

## 📁 Directory Structure | 目录结构

```text
.
├── init.lua                 # 入口
├── lazy-lock.json           # 插件锁定文件
├── stylua.toml              # Lua 格式化配置
├── lua/
│   ├── config/              # 基础配置（options / keymaps / autocmd）
│   └── plugins/             # 插件模块
│       ├── lsp.lua
│       ├── blink-cmp.lua
│       ├── snacks.lua
│       ├── dap.lua
│       ├── ui.lua
│       ├── theme.lua
│       ├── formatter.lua
│       └── ...
└── Readme.md
```

---

## 🔌 Plugins Overview | 插件概览

| Category    | Plugin / 状态 |
| ----------- | ------------- |
| LSP         | `vim.lsp.config()` / `vim.lsp.enable()` + `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim` |
| Tooling     | `mason-tool-installer.nvim` |
| Completion  | `blink-cmp`, `LuaSnip`, `friendly-snippets`, `lspkind.nvim` |
| UI / Picker | `snacks.nvim`, `bufferline.nvim`；Noice / Trouble / lualine 已移除，cmdline/messages、diagnostics quickfix 与 statusline 使用 Neovim 原生实现 |
| Theme       | `catppuccin` / Catppuccin Mocha（当前唯一 active theme；历史主题候选不再保留在 active config 中） |
| File Tree   | `neo-tree.nvim` |
| Outline     | Neovim 原生 `gO` / `<leader>o` document symbols |
| Syntax      | `nvim-treesitter`, `nvim-treesitter-textobjects` |
| Formatting  | `conform.nvim` |
| Git         | `gitsigns.nvim` + snacks git pickers |
| Editing     | `nvim-autopairs`, `nvim-colorizer.lua`；滚动使用 Neovim 原生命令 |
| Markdown / LaTeX | `markdown-preview.nvim`, `vimtex` |
| AI          | `avante.nvim` |
| Debug       | DAP 当前未启用 |

---

## ⌨️ Key Philosophy | 设计理念

* **Less but better**
  少即是多，但留下的必须是精品
* **Readable > Fancy**
  可读性优先于炫技
* **Native first**
  优先使用 Neovim 原生能力
* **No IDE cosplay**
  不把 Neovim 变成 VSCode

---

## 🖥 Requirements | 环境要求

* Neovim **0.12.x**
* Git
* Node / Python / C/C++ toolchain（视语言而定）

---

## 🚧 Status | 状态

* 持续演进中
* 偏向 **个人生产力配置**
* 不保证向后兼容

---


## 🙋 Notes

This configuration is **opinionated**.
Steal whatever you like, ignore the rest.

这是一份**有明确取舍的配置**，
不是“什么都要”的大杂烩。
