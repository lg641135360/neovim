-- 基础编辑选项入口，在 lazy.nvim 启动前加载。

require("config.options.base").setup()
require("config.options.ui").setup()
require("config.options.diagnostics").setup()
require("config.options.commands").setup()
