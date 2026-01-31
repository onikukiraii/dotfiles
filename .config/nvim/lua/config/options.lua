-- 基本オプション設定
local opt = vim.opt

-- 行番号
opt.number = true
opt.relativenumber = false  -- true にすると相対行番号

-- マウス有効（Helixと同じ）
opt.mouse = "a"

-- クリップボード連携（システムクリップボード）
opt.clipboard = "unnamedplus"

-- True Color有効
opt.termguicolors = true

-- シンタックスハイライト有効
vim.cmd("syntax enable")

-- サインカラム常時表示（git signs, diagnostics用）
opt.signcolumn = "yes"

-- 更新間隔
opt.updatetime = 250
opt.timeoutlen = 300

-- インデント
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- 検索
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- ファイル
opt.swapfile = false
opt.backup = false
opt.undofile = true

-- カーソル形状（Helixライク: normal=block, insert=bar, select=underline）
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- 自動再読み込み（外部で変更されたファイル）
opt.autoread = true

-- スクロール
opt.scrolloff = 8
opt.sidescrolloff = 8

-- 分割
opt.splitright = true
opt.splitbelow = true

-- 行の折り返し
opt.wrap = false

-- 補完
opt.completeopt = "menu,menuone,noselect"

-- 不可視文字
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
