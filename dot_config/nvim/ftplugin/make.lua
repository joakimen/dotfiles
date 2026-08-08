-- Recipes need real tabs, but nvim's own ftplugin/make.vim already sets
-- noexpandtab/softtabstop/shiftwidth and runs after this file. Only the render
-- width is left to choose, and it must be buffer-local so it doesn't leak.
vim.bo.tabstop = 2
