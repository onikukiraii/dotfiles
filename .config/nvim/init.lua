-- Neovim設定のエントリーポイント

-- リーダーキーを先に設定（プラグイン読み込み前に必要）
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 基本設定の読み込み
require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
