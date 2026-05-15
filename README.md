# Neovim Configuration

> 个人 Neovim 0.12 配置：以 **原生 LSP + blink-cmp + snacks.nvim** 为主，保留少量明确有价值的插件体验；核心 UX 插件多为 eager，以稳定日常 UX。
> 这份文档优先回答“日常怎么用”，尤其是快捷键。

---

## 快速开始

- `<leader>` 是空格键，也就是下文的 `<leader>x` 等价于 `Space` 后再按 `x`。
- 常用文件入口：`nvim .` 打开目录，`<leader>e` 切换 Neo-tree，`<leader>ff` 找文件（包含隐藏文件/目录），`<leader>fg` 全项目搜索。
- 当前词 / 选区直搜：`<leader>sw`
- 保存与关闭：`<C-s>` / `<leader>w` 保存，`:q` / `<leader>q` 关闭当前文件 buffer，`<leader>c` 强制关闭当前 buffer。
- 当前文件格式化：`<leader>fm`
- 诊断交互：`<leader>df` 看当前行诊断，`<leader>dj` / `<leader>dk` 跳到下一个 / 上一个诊断并弹出浮窗。
- 位置历史：`<A-Left>` / `<A-Right>` 像 VSCode 一样在 jumplist 中后退 / 前进。
- 成对输入由本地 native pairs helper 处理基础括号/引号、空 pair 删除、闭合符跳过和空 pair 回车展开。
- 命令行体验：`:` / `/` / `?` 使用 Noice 的 `cmdline_popup` 浮动命令行。
- 浮窗、补全菜单、搜索当前项和 Visual 选区现在直接跟随 Catppuccin Mocha 默认非透明配色，不再额外强制透明或套用旧色板覆盖。

---

## 一、文件 / Buffer / 窗口

| 快捷键 | 模式 | 行为 |
| --- | --- | --- |
| `<leader>ff` | Normal | 查找文件，默认包含隐藏文件/目录；不默认包含 ignored/gitignored |
| `<leader>fb` | Normal | 查找已打开 buffers |
| `<leader>fr` | Normal | 最近文件 |
| `<leader>fp` | Normal | 项目列表 |
| `<leader>e` | Normal | 切换 Neo-tree 文件树 |
| `<leader><PageDown>` / `<leader><PageUp>` | Normal | 下一个 / 上一个 buffer |
| `<leader>1` ... `<leader>9` | Normal | 跳到对应序号 buffer |
| `<leader>tb` | Normal | 显示 / 隐藏原生 tabline |
| `<leader><Left/Down/Up/Right>` | Normal | 在窗口间移动焦点 |

说明：
- Buffer 列表使用 Neovim 原生 tabline，`showtabline=2`，不再依赖额外 tabline 插件。
- 状态栏使用原生 `statusline` + `laststatus=3`，显示 mode、文件名、modified/readonly、diagnostic counts、filetype 与位置。
- Neo-tree 左侧 sidebar 使用整数宽度 `40`，避免 Neovim 窗口 API 收到小数宽度。
- Neo-tree 目前明确保留：隔离 netrw/native POC 无法同时满足 follow current file、Git status、hidden/gitignored 可见性等文件树 parity 要求，因此不为减少插件牺牲 `<leader>e` 左侧文件树体验。
- 在当前目录工作流里，关闭文件后再用 `<leader>e` 收起 Neo-tree 会回到空 buffer，不会因为没有普通文件窗口就直接退出 Neovim。

---

## 二、保存 / 关闭 / 退出

| 快捷键 | 模式 | 行为 |
| --- | --- | --- |
| `<C-s>` | Normal / Insert / Visual | 快速保存当前文件 |
| `<leader>w` | Normal | 保存当前文件 |
| `:q` / `:quit` | Command | 关闭当前文件 buffer，不退出 Neovim |
| `<leader>q` | Normal | 关闭当前文件 buffer，不退出 Neovim |
| `<leader>c` | Normal | 强制删除当前 buffer，丢弃未保存状态 |

`:q` / `<leader>q` 的细节：
- 使用 Lua 包装的 `:bdelete`，目标是“关闭当前文件”而不是关闭窗口。
- 从 `nvim .` + Neo-tree 打开文件后，`:q` / `<leader>q` 不会因为当前文件窗口是最后一个普通编辑窗口而退出整个 Neovim。
- 如果当前文件有未保存修改，会把 Neovim 原生命令错误文本转给 Snacks 浮动通知显示，并取消关闭。
- 如果当前是未命名、未修改的空 buffer，则 `:q` / `<leader>q` 会直接退出 Neovim。
- 真正要退出已有文件会话时，使用 `:qa` / `:qall` 等显式退出命令。

---

## 三、搜索 / Picker

| 快捷键 | 模式 | 行为 |
| --- | --- | --- |
| `<leader>fg` | Normal | 全项目 grep 搜索 |
| `<leader>sw` | Normal / Visual | 搜索当前词或当前选区 |
| `<leader>:` | Normal | command history |
| `<leader>/` | Normal | search history |
| `<leader>sd` | Normal | diagnostics picker |
| `<leader>gs` | Normal | Git status picker |
| `<leader>gd` | Normal | Git diff hunks picker |
| `<leader>nh` | Normal | notification history，查看完整警告 / 历史通知 |

搜索补充：
- `<leader>ff` 使用 snacks files picker，默认能搜到 `.config/...` 这类隐藏路径，但不默认包含 ignored/gitignored 文件。
- `<leader>sw` 使用 `Snacks.picker.grep_word()`：普通模式搜索光标下单词，Visual 模式搜索当前选区。
- 在 picker 内可用 `<A-h>` 切换 hidden/隐藏文件显示，用 `<A-i>` 切换 ignored/忽略文件显示。
- 当前日常只保留 `<leader>fg` 作为全项目 grep 主入口。
- VSCode 风格的 include / exclude / 大小写 / 整词 / 普通文本 / 大文件限制等高级搜索能力先作为后续优化方向，不在当前快捷键里展开。
- snacks.nvim 继续负责 picker、notifier、input；Notifier 弹窗默认保留 8 秒，长警告可通过 notification history 查看完整内容。
- Dashboard 不启用，启动页回到 Neovim 原生空 buffer。

---

## 四、LSP / 代码导航 / 诊断

| 快捷键 / 命令 | 模式 | 行为 |
| --- | --- | --- |
| `gd` | Normal | 跳转 definition |
| `gD` | Normal | 跳转 declaration |
| `<A-Left>` / `<A-Right>` | Normal | 位置历史后退 / 前进，对应 Vim jumplist 的 `<C-o>` / `<C-i>` |
| `grr` | Normal | references picker |
| `gI` | Normal | implementations picker |
| `gy` | Normal | type definition picker |
| `gai` / `gao` | Normal | incoming / outgoing calls |
| `<leader>ss` / `<leader>sS` | Normal | document symbols / workspace symbols |
| `<leader>o` | Normal | Neovim 原生 LSP document symbols outline；同类默认入口是 `gO` |
| `<leader>rn` | LSP buffer | LSP buffer-local rename；同类 Neovim 0.12 默认入口是 `grn` |
| `<leader>ca` | LSP buffer | code action；同类 Neovim 默认入口包括 `gra` |
| `<leader>th` | LSP buffer | server 支持时切换 inlay hints |
| `K` | LSP buffer | hover documentation |
| `<leader>df` | Normal | 打开当前行 diagnostics 浮窗 |
| `<leader>dj` / `<leader>dk` | Normal | 跳到下一个 / 上一个 diagnostic，并显示浮窗 |
| `<leader>xx` | Normal | 打开 Neovim 原生 diagnostics quickfix |
| `:lua =vim.lsp.get_clients({bufnr=0})` / `:lsp restart clangd` | Command | 查看当前 buffer 的 LSP client；clangd 已附着时重启 clangd |

LSP 配置说明：
- 使用 Neovim 内置 `vim.lsp.config()` / `vim.lsp.enable()`；LSP server 的唯一启用权威是 `vim.lsp.enable()`。
- 启用 server：`lua_ls`、`clangd`、`pyright`、`ts_ls`。
- `<leader>rn` 只作为 LSP buffer-local rename alias，和 `grn` 一起调用 Neovim 原生 rename。
- `grr` 使用 snacks.nvim references picker，对齐 Neovim 0.12 references 默认语义。
- 浮窗和补全菜单使用 `winborder` / `pumborder` 统一 rounded 风格。
- 诊断行内提示使用 Neovim 原生 `virtual_text`，`virt_text_pos = "inline"`；diagnostic signs 关闭，`virtual_lines` 关闭。
- `<leader>df` 使用 Neovim 原生 diagnostics float 查看当前行；`<leader>dj` / `<leader>dk` 会在跳转时自动弹出诊断浮窗。
- `<leader>xx` 使用 quickfix，`<leader>sd` 使用 snacks diagnostics picker。

---

## 五、补全 / Snippet

| 快捷键 | 模式 | 行为 |
| --- | --- | --- |
| `<Tab>` / `<S-Tab>` | Insert / completion menu | 选择下一项 / 上一项，或跳转 snippet 占位符 |
| `<CR>` | Insert / completion menu | 接受当前补全项 |
| `<C-space>` | Insert | 显示补全和文档 |
| `<C-k>` | Insert | 显示 / 隐藏 signature help |

说明：
- 使用 `blink-cmp`，默认 sources 为 `lsp`、`path`、`snippets`、`buffer`。
- Completion kind icons 使用本地映射；path source 继续通过 `nvim-web-devicons` 显示文件图标。
- `blink-cmp` 仍拥有补全菜单中的 `<Tab>` / `<S-Tab>` / `<CR>` 语义；native pairs helper 只在补全菜单不可见且光标位于空 pair 内时处理 `<CR>` 展开。

---

## 五点五、原生 pairs

| 快捷键 | 模式 | 行为 |
| --- | --- | --- |
| `(` / `[` / `{` / `'` / `"` | Insert | 插入基础成对字符，并把光标停在 pair 中间 |
| `<BS>` | Insert | 光标位于空 pair 中间时成对删除 |
| `)` / `]` / `}` / `'` / `"` | Insert | 右侧已有匹配闭合符时跳过已有字符 |
| `<CR>` | Insert | 在空 `()` / `[]` / `{}` 中展开中间空行；补全菜单可见时仍优先接受 `blink.cmp` 补全 |

说明：
- 行为来自 `lua/config/autopairs.lua` 的本地 Neovim 原生 helper，不再加载 `nvim-autopairs` 插件。
- 该 helper 只覆盖本轮 POC 选中的最小 parity gate；如果未来需要 Treesitter / filetype-specific 规则，应单独评估，而不是把 helper 扩成第二套插件系统。

---

## 六、编辑 / 选择 / 缩进

| 快捷键 | 模式 | 行为 |
| --- | --- | --- |
| `<A-Up>` / `<A-Down>` | Normal | 移动当前行上 / 下 |
| `<A-Up>` / `<A-Down>` | Visual | 移动选中的多行上 / 下 |
| `<S-A-Up>` / `<S-A-Down>` | Normal | 复制当前行到上方 / 下方 |
| `<S-A-Up>` / `<S-A-Down>` | Visual | 复制选中的多行到上方 / 下方 |
| `vv` | Normal | 选择匹配块 |
| `vc` | Normal | 选择当前词 |
| `vl` | Normal | 选择当前行 |
| Visual `<Tab>` / `<S-Tab>` | Visual | 增加 / 减少缩进 |
| `<Esc>` | Normal | 清除搜索高亮 |
| `<Esc>` | Terminal | 回到 Normal 模式 |
| `<C-a>` | Normal | 全选 |
| `<C-c>` / `<C-x>` / `<C-v>` | Normal / Visual | 使用系统剪贴板复制 / 剪切 / 粘贴 |
| `gc` / `gcc` | Normal / Visual | Neovim 原生注释 |

说明：
- 行移动与复制使用本地 Lua buffer 操作，不依赖插件，也不污染默认寄存器。
- 终端必须能把 Alt 方向键组合传给 Neovim；当前仓库的 Alacritty Linux / macOS profile 已显式发送对应 xterm modifier 序列。
- 滚动使用 Neovim 原生命令，不启用额外滚动插件。

---

## 七、命令行 / 通知 / 浮动终端

| 快捷键 / 命令 | 模式 | 行为 |
| --- | --- | --- |
| `:` / `/` / `?` | Normal | Noice `cmdline_popup` 浮动命令行 |
| `<leader>nh` | Normal | 打开 notification history |
| `<leader>ft` | Normal | 打开自定义浮动终端 |
| `:Hv {topic}` | Command | 垂直窗口打开 help |

说明：
- Noice 只负责 `cmdline_popup` 浮动命令行；普通 messages、notify、LSP hover/signature 不交给 Noice。
- snacks.nvim notifier / input 继续负责通知与输入类 UI。

---

## 八、CMake / clangd 辅助命令

| 命令 | 行为 |
| --- | --- |
| `:CMakeUserPresetInit` | 在当前 CMake 项目生成本地 `CMakeUserPresets.json` |
| `:CMakeUserPresetInit!` | 强制覆盖生成本地 `CMakeUserPresets.json` |
| `:CMakeConfigure` | 有 user preset 时自动使用 `nvim-debug`；若不存在则使用第一个 `configurePresets[].name`；否则 fallback 到 `cmake -S <root> -B <root>/build` |
| `:CMakeConfigure {preset}` | 使用指定 configure preset；如果传入 build preset，会自动转到它的 `configurePreset` |

说明：
- `:CMakeUserPresetInit` 生成的默认 preset 名为 `nvim-debug`，`binaryDir = ${sourceDir}/build`，generator 为 Ninja。
- 已有项目如果只有 `linux-base` 这类自定义 preset，直接执行 `:CMakeConfigure` 会自动选择它；也可以显式执行 `:CMakeConfigure linux-base`。`linux-build` 这类 build preset 不是 configure preset，但本配置会自动读取它的 `configurePreset` 字段。
- 配合当前 clangd 的 `--compile-commands-dir=build`，项目 CMake 已启用 `CMAKE_EXPORT_COMPILE_COMMANDS` 时会生成 `build/compile_commands.json`。
- 如果 clangd 诊断或跳转结果没有刷新，先执行 `:lua =vim.lsp.get_clients({bufnr=0})` 确认当前 buffer 已有 `clangd` client；已附着时再执行 `:lsp restart clangd`。若提示 `no active clients named clangd`，说明 clangd 当前没有附着到这个 buffer。
- `filetype=cpp` 但 client 仍是 `{}` 时，继续检查：`:lua print(vim.lsp.is_enabled("clangd"))`、`:lua print(vim.fn.executable("clangd"), vim.fn.exepath("clangd"))`、`:lua =vim.fs.root(0, {"CMakeLists.txt", "CMakePresets.json", "CMakeUserPresets.json", "compile_commands.json", ".git"})`；若 `executable("clangd") = 0`，先安装 clangd 并让它进入 Neovim 的 `PATH`。修复后重启 Neovim 或对该文件执行 `:edit` 触发重新 attach。
- 新环境 clangd 入口约定：优先把机器/厂商特定 clangd 安装在任意版本化目录，再用 `~/.local/bin/clangd` 作为稳定入口软链；不要把 `/usr/local/musa/bin` 这类机器路径写进共享 dotfiles。示例：

  ```bash
  mkdir -p ~/.local/bin
  ln -sf /path/to/clangd/bin/clangd ~/.local/bin/clangd
  command -v clangd
  clangd --version
  nvim --headless -u NONE '+lua print(vim.fn.exepath("clangd"))' '+qa!'
  ```

  在 `wh_fabric_build` 上已验证 `~/.local/bin/clangd -> /home/fm/code/clangd/clangd_20.1.0/bin/clangd`。

---

## 九、工具链 / 格式化

- `<leader>fm`：格式化当前文件，优先走 `conform.nvim`，必要时 fallback 到 LSP formatter。
- `mason.nvim` 负责工具链入口；LSP server 启用由原生 `vim.lsp.enable()` 负责，不再通过 Mason LSP 桥接插件桥接。
- `mason-tool-installer.nvim` 在交互式 Neovim 启动后延迟补齐常用格式化/CLI 工具；headless 测试 / 脚本启动会跳过自动安装等 Mason 网络和写入副作用。clangd 语言服务器优先使用系统或用户 PATH 中的 `clangd`。
- `conform.nvim` 负责格式化：Lua 使用 `stylua`，Python 使用 `black` / `isort`，Web/JSONC 使用 `prettier`，JSON 使用 `jq`，Shell 使用 `shfmt`，C/C++ 使用 `clang-format`，TeX 使用 `tex-fmt`。
- DAP 当前未启用，默认不加载调试插件；如需调试能力应单独添加项目级配置。
- 自动文件头不启用；如需模板请使用项目级 snippets / skeleton 单独配置。
- 颜色预览不启用。

---

## 插件与 UI 状态速览

| Category | Plugin / 状态 |
| --- | --- |
| LSP | `vim.lsp.config()` / `vim.lsp.enable()` + `nvim-lspconfig`；Mason LSP 桥接插件已移除 |
| Tooling | `mason-tool-installer.nvim` |
| Completion | `blink-cmp`, `LuaSnip`, `friendly-snippets`；completion kind icons 使用本地映射 |
| UI / Picker | `snacks.nvim` + `noice.nvim` 窄配置；Noice 只负责 `cmdline_popup` 浮动命令行；diagnostics quickfix、statusline 与 tabline 使用 Neovim 原生实现 |
| Theme | `catppuccin` / Catppuccin Mocha |
| File Tree | `neo-tree.nvim`；整数宽度 `40`；保留 follow current file、Git status、hidden/gitignored 可见性 |
| Outline | Neovim 原生 `gO` / `<leader>o` document symbols |
| Syntax | `nvim-treesitter`；语法高亮 / 缩进由 Treesitter 本体负责；对 Neovim 0.12 下 query predicates 的重复 capture 做了本地兼容补丁 |
| Formatting | `conform.nvim` |
| Git | `gitsigns.nvim` + snacks git pickers |
| Editing | native pairs helper；滚动使用 Neovim 原生实现 |
| Markdown / LaTeX | `markdown-preview.nvim`, `vimtex` |
| AI | `avante.nvim` |

补充：
- `avante.nvim` 依赖的 `render-markdown.nvim` 会走 Treesitter markdown query。当前对 `nvim-treesitter` 的 query predicates 做了本地兼容层：当 Neovim 0.12 把重复 capture 传成节点列表时，先解成首个 `TSNode`，避免 `render-markdown` / fenced code block 一类场景再出现 `attempt to call method 'range' (a nil value)`。

---

## 目录结构

```text
.
├── init.lua
├── lazy-lock.json
├── stylua.toml
├── lua/
│   ├── config/      # options / keymaps / autocmds / cmake / lazy
│   └── plugins/     # lsp / blink-cmp / snacks / ui / formatter / ...
└── README.md
```

---

## 环境要求

- Neovim 0.12.x
- Git
- Node / Python / C/C++ toolchain（按语言需要）
- CMake / Ninja（仅 CMake 项目需要）
