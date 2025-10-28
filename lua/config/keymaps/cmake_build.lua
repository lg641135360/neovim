local cmake_build = {}

local project_root = vim.fn.getcwd() -- 当前项目根目录
local build_dir = project_root .. "/build"

local clang_executable = "/usr/local/bin/clang"  -- Clang 编译器路径
local clangxx_executable = "/usr/local/bin/clang++"  -- Clang++ 编译器路径

-- 复用 terminal
local term_buf = nil
local term_chan = nil

-- 假设 terminal.lua 已经在 lua/keymaps/terminal.lua
local term_module = require("keymaps.float_terminal")

-- 在浮窗终端执行命令，并可自动打开日志
local function run_in_float_terminal(cmd, log_file)
	-- 打开浮窗终端
	--[[ local chan = term_module.open() ]]

	-- 进入插入模式
	--[[ vim.cmd("startinsert") ]]

	-- 发送命令
	-- vim.fn.chansend(chan, cmd .. "\r")
	term_module.send(cmd)
	-- 退出插入模式
	vim.cmd("stopinsert")
	-- 可选：显示日志文件
	-- if log_file then
	--     vim.defer_fn(function()
	--         if vim.fn.filereadable(log_file) == 1 then
	--             vim.cmd("edit " .. log_file)
	--             vim.cmd("normal! G")
	--         end
	--     end, 1200)
	-- end
end

-- F6: 配置 CMake 项目
function cmake_build.configure()
	if vim.fn.isdirectory(build_dir) == 0 then
		vim.fn.mkdir(build_dir)
		print("Created build directory: " .. build_dir)
	end

	-- 配置 CMake 的命令
	local cmd = string.format(
		'cd "%s" && cmake .. -G Ninja -DCMAKE_C_COMPILER="%s" -DCMAKE_CXX_COMPILER="%s"',
		build_dir, clang_executable, clangxx_executable
	)

	run_in_float_terminal(cmd, build_dir .. "/cmake_configure.log")
end

-- F7: 编译项目
function cmake_build.build()
	if vim.fn.isdirectory(build_dir) == 0 then
		print("Build directory does not exist. Please configure the project with F6 first.")
		return
	end

	-- 编译项目，并输出日志到 cmake_build.log
	local cmd = string.format(
		'cd "%s" && cmake --build . --parallel --config Debug > cmake_build.log 2>&1',
		build_dir
	)

	run_in_float_terminal(cmd, build_dir .. "/cmake_build.log")
end

-- F8: 运行项目
function cmake_build.run()
	local cmd = string.format(
		'cd "%s" && ./*.out', build_dir  -- 假设编译出的可执行文件是 .out 文件
	)

	run_in_float_terminal(cmd, build_dir .. "/run_output.log")
end

return M
