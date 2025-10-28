local float_term = {}

float_term.term_buf = nil
float_term.term_win = nil
float_term.term_chan = nil

local float_width = 0.75
local float_height = 0.75

-- 打开或复用浮窗终端
function float_term.open()
	if float_term.term_buf and vim.api.nvim_buf_is_valid(float_term.term_buf) then
		if float_term.term_win and vim.api.nvim_win_is_valid(float_term.term_win) then
			vim.api.nvim_set_current_win(float_term.term_win)
		else
			-- 重新创建窗口
			local width = math.floor(vim.o.columns * float_width)
			local height = math.floor(vim.o.lines * float_height)
			local row = math.floor((vim.o.lines - height) / 2)
			local col = math.floor((vim.o.columns - width) / 2)
			float_term.term_win = vim.api.nvim_open_win(float_term.term_buf, true, {
				style = "minimal",
				relative = "editor",
				width = width,
				height = height,
				row = row,
				col = col,
				border = "rounded",
			})
		end
		vim.cmd("startinsert")
		return float_term.term_chan
	end

	-- 创建新的 buffer
	float_term.term_buf = vim.api.nvim_create_buf(false, true)

	local width = math.floor(vim.o.columns * float_width)
	local height = math.floor(vim.o.lines * float_height)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	float_term.term_win = vim.api.nvim_open_win(float_term.term_buf, true, {
		style = "minimal",
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = "rounded",
	})

	-- Linux 使用 zsh 打开交互终端
	float_term.term_chan = vim.fn.termopen({ "zsh", "-i" }, { detach = 0 })

	vim.cmd("startinsert")

	return float_term.term_chan
end

-- 发送命令到浮窗终端
function float_term.send(cmd)
	local chan = float_term.open()
	vim.fn.chansend(chan, cmd .. "\n")
end

-- 清空浮窗终端
function float_term.clear()
	if float_term.term_buf and vim.api.nvim_buf_is_valid(float_term.term_buf) then
		vim.api.nvim_buf_set_lines(float_term.term_buf, 0, -1, false, {})
	end
end

return float_term

