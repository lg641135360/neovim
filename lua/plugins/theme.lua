-- plugins/theme.lua

-- 定义你想用的主题名字
-- 可选: "tokyonight" 或 "catppuccin"
local active_theme = "catppuccin"

-- 定义一个通用函数，用于在主题加载后设置自定义高亮
local function apply_custom_highlights()
	-- 折叠行颜色（Folded）
	vim.api.nvim_set_hl(0, "Folded", {
		bg = "#2a2734", -- 背景色：深灰
		italic = true,
	})

	-- 💠 设置透明补全菜单
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" }) -- 所有浮窗透明
	vim.api.nvim_set_hl(0, "Pmenu", { bg = "NONE", blend = 0 }) -- 补全菜单透明
	vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#5fbdd5", fg = "#1e1e2e", bold = true }) -- 选中项
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#89dceb", bg = "NONE" }) -- 边框保留
end

-- 当主题重新加载时自动应用这些高亮
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = apply_custom_highlights,
})

-- 定义主题配置表
local themes = {
	-- tokyonight
	tokyonight = {
		"folke/tokyonight.nvim",
		config = function()
			require("tokyonight").setup({
				style = "storm", -- 可选: "storm", "night", "moon", "day"
				transparent = true,
				terminal_colors = true,
				styles = {
					sidebars = "transparent",
					floats = "transparent",
				},
				on_highlights = function(hl, c)
					-- 这里修改 Comment 颜色（绝对生效）
					hl.Comment = { fg = "#d7a9b8", italic = true }
				end,
			})
			vim.cmd("colorscheme tokyonight")
			apply_custom_highlights()
		end,
	},

	-- catppuccin
	catppuccin = {
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				flavour = "macchiato", -- 可选: "latte", "frappe", "macchiato", "mocha"
				background = { light = "latte", dark = "mocha" },
				transparent_background = true,
				term_colors = true,
				styles = {
					comments = { "italic" },
					-- functions = { "bold" },
					-- keywords = { "italic" },
				},
				integrations = {
					telescope = true,
					nvimtree = true,
					treesitter = true,
					notify = true,
				},
			})
			vim.cmd("colorscheme catppuccin")
			apply_custom_highlights()
		end,
	},

	-- gruvbox
	gruvbox = {
		"ellisonleao/gruvbox.nvim",
		config = function()
			require("gruvbox").setup({
				contrast = "medium", -- 可选: "hard", "medium", "soft"
				transparent_mode = true, -- 背景透明
			})
			vim.cmd("colorscheme gruvbox")
			apply_custom_highlights()
		end,
	},

	-- Nightfox 主题配置
	nightfox = {
		"EdenEast/nightfox.nvim",
		config = function()
			require("nightfox").setup({
				options = {
					-- 背景透明（浮动窗口、侧边栏等）
					transparent = false,
					-- 设置终端颜色
					terminal_colors = true,
					-- 非激活窗口背景
					dim_inactive = false,
					-- 默认模块启用
					module_default = true,
					-- 样式设置
					styles = {
						comments = "italic",
						conditionals = "italic",
						constants = "NONE",
						functions = "bold",
						keywords = "bold,italic",
						numbers = "NONE",
						operators = "NONE",
						strings = "NONE",
						types = "italic",
						variables = "NONE",
					},
				},
			})

			-- 设置颜色方案
			vim.cmd("colorscheme duskfox")
			apply_custom_highlights()
		end,
	},

	fluoromachine = {
		{
			"maxmx03/fluoromachine.nvim",
			lazy = false,
			priority = 1000,
			config = function()
				local fm = require("fluoromachine")

				fm.setup({
					glow = true,
					theme = "delta",
					transparent = true,
				})

				vim.cmd("colorscheme fluoromachine")
			end,
		},
	},
}

-- 返回当前激活的主题配置
return { themes[active_theme] }

