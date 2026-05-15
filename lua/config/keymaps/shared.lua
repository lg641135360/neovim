local M = {}

M.map = vim.keymap.set
M.opts = { noremap = true, silent = true }

function M.opts_with_desc(desc)
  return vim.tbl_extend("force", M.opts, { desc = desc })
end

return M
