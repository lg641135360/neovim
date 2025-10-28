-- lua/plugins/noice.lua
return {
	"folke/noice.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim", -- 必须
		"rcarriga/nvim-notify", -- 可选通知
	},
	config = function()
		-- 使用 nvim-notify 替换 vim.notify
		vim.notify = require("notify")
		vim.notify = function(msg, level, opts)
			if level == vim.log.levels.WARN then
				return
			end
			require("notify")(msg, level, opts)
		end

		require("notify").setup({
			-- 背景
			background_colour = "#000000",
			render = "compact",
			stages = "slide",
			fps = 120,
			timeout = 2000,
			icons = {
				ERROR = "",
				WARN = "",
				INFO = "",
				DEBUG = "",
				TRACE = "✎",
			},
			minimum_width = 40, -- 最小宽度
		})

		require("noice").setup({
			-- 命令行配置
			cmdline = {
				enabled = true, -- 启用 Noice 命令行
				view = "cmdline_popup", -- 浮窗形式
				format = {
					cmdline = { pattern = "^:", icon = "", lang = "vim" },
					search_down = { pattern = "^/", icon = "", lang = "regex" },
					search_up = { pattern = "^%?", icon = "", lang = "regex" },
					lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
				},
			},

			-- 消息配置
			messages = {
				enabled = true,
				view = "notify", -- 错误、警告、消息都使用 notify
				view_error = "notify",
				view_warn = "notify",
				view_history = "messages",
				view_search = "virtualtext",
			},

			-- popupmenu 配置（completion 列表）
			popupmenu = {
				enabled = false,
				backend = "nui",
			},

			-- LSP 配置
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
				progress = { enabled = true, view = "mini" },
				hover = { enabled = true },
				signature = { enabled = true },
				message = { enabled = true, view = "notify" },
			},

			-- 预设
			presets = {
				bottom_search = false,
				command_palette = false,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = true,
			},
		})
	end,
}
