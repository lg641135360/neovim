# Neovim Configuration

> 🧠 A modern, fast, and opinionated Neovim setup  
> 基于 **LSP + blink-cmp + snacks.nvim** 的现代化 Neovim 个人配置

---

## ✨ Features | 特性

- 🚀 **Fast startup** – 基于 `lazy.nvim` 的按需加载
- 🧩 **LSP-centric** – 以原生 LSP 为核心，而非 IDE 模拟
- ⚡ **blink-cmp** – 极速、简洁的补全体验
- 🍿 **snacks.nvim** – Picker / UI / Notifier 一体化方案
- 🧭 **Neovim 0.12 defaults** – 优先使用内置 `gc/gcc` 注释与 LSP 默认能力
- 🎨 **Clean UI** – 克制、透明、可读性优先
- 🛠 **Highly modular** – 插件按功能拆分，易维护

---

## 🧱 Core Architecture | 核心架构

### 🔹 LSP (Language Server Protocol)

- 使用 **Neovim 内置 LSP**，配置主线对齐 0.12 `vim.lsp.config()` / `vim.lsp.enable()`
- `mason.nvim` 负责 LSP / Formatter / DAP 管理
- `nvim-lspconfig` 保留为 server config 数据来源，不再使用旧的 `lspconfig.SERVER.setup()` 主线
- `lsp.lua` 统一配置：
  - `blink.cmp` LSP capabilities
  - LSP buffer-local alias keymaps
  - inlay hints
  - server-specific settings
  - `lua_ls` 显式声明 Neovim LuaJIT runtime、`vim` global 与 runtime `workspace.library`，不再依赖旧 `neodev.nvim` hook

> 目标：**让编辑器理解代码，而不是堆插件**

---

### 🔹 Neovim 0.12 defaults

- 注释优先使用 Neovim 内置 `gc` / `gcc`。
- LSP 默认键位包括 `grn`、`gra`、`grr`、`gri`、`grt`、`grx`、`gO`。
- 当前保留旧 alias：`<leader>rn`、`<leader>ca`、`K`。
- `grr` 使用 `snacks.nvim` references picker，对齐 Neovim 0.12 references 默认语义。
- `<leader>rn` 现在只作为 LSP buffer-local rename alias，和 `grn` 一起调用 Neovim 原生 rename。
- 浮窗与补全菜单默认使用 0.12 `winborder` / `pumborder` 统一为 `rounded`；诊断浮窗同样使用 rounded border，并只在多来源时显示 source。
- 诊断行内提示使用 Neovim 原生 `virtual_text` + `virt_text_pos = "inline"`，避免额外诊断显示插件。

---

### 🔹 Editing keymaps

- `<A-Up>` / `<A-Down>`：普通模式移动当前行，visual 模式移动选中的多行。
- `<S-A-Up>` / `<S-A-Down>`：普通模式复制当前行到上方 / 下方，visual 模式复制选中的多行到上方 / 下方。
- 行移动与复制使用本地 Lua buffer 操作，不依赖额外插件，也不通过默认寄存器实现。

---

### 🔹 Completion – blink-cmp

- 使用 [`blink-cmp`](https://github.com/Saghen/blink.cmp)
- 替代传统 `nvim-cmp`
- 特点：
  - 更快
  - 更少魔法
  - 更清晰的 source 管理

配置文件：
`lua/plugins/blink-cmp.lua`

---

### 🔹 UI / Picker – snacks.nvim

- 使用 [`folke/snacks.nvim`](https://github.com/folke/snacks.nvim)
- 替代：
  - telescope
  - notify
  - 部分 UI 插件

主要功能：
- Picker（文件 / LSP / Git）
- Notifier
- Indent / UI enhancements

配置文件：
`lua/plugins/snacks.lua`

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
└── README.md
```

---

## 🔌 Plugins Overview | 插件概览

| Category    | Plugin                         |
| ----------- | ------------------------------ |
| LSP         | `vim.lsp.config()` / `vim.lsp.enable()` + `nvim-lspconfig`, `mason.nvim` |
| Completion  | `blink-cmp`                    |
| UI / Picker | `snacks.nvim`                  |
| File Tree   | `neo-tree.nvim`                |
| Debug       | `nvim-dap`                     |
| Syntax      | `nvim-treesitter`              |
| Formatting  | `conform.nvim` / formatter     |
| Git         | 内置 + snacks picker             |

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
