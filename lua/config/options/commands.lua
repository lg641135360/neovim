local M = {}

function M.setup()
  -- 创建 :Hv 命令，在垂直帮助窗口中打开帮助
  vim.api.nvim_create_user_command("Hv", function(opts)
    vim.cmd("vertical help " .. (opts.args ~= "" and opts.args or ""))
  end, { nargs = "*", complete = "help" })
end

return M
