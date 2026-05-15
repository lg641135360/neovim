-- 自定义快捷键入口。

vim.g.mapleader = " " -- 空格为 leader

require("config.keymaps.navigation").setup()
require("config.keymaps.session").setup()
require("config.keymaps.editing").setup()
