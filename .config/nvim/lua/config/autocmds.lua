-- 自動コマンド
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ファイル変更時の自動再読み込み（auto reload）
augroup("AutoReload", { clear = true })
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = "AutoReload",
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
  desc = "Auto reload file when changed externally",
})

-- ファイル変更通知
autocmd("FileChangedShellPost", {
  group = "AutoReload",
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
  desc = "Notify when file is reloaded",
})

-- Yank時のハイライト
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
  desc = "Highlight on yank",
})

-- 最後のカーソル位置を復元
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = "Restore cursor position",
})

-- 保存時に末尾の空白を削除
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  callback = function()
    -- modifiableでないバッファはスキップ
    if not vim.bo.modifiable then
      return
    end
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  desc = "Trim trailing whitespace on save",
})

-- ターミナルモードでの設定
augroup("TerminalSettings", { clear = true })
autocmd("TermOpen", {
  group = "TerminalSettings",
  pattern = "*",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
  desc = "Terminal settings",
})

-- ヘルプを右側に開く
augroup("HelpWindow", { clear = true })
autocmd("FileType", {
  group = "HelpWindow",
  pattern = "help",
  callback = function()
    vim.cmd("wincmd L")
  end,
  desc = "Open help in vertical split",
})

-- 特定のファイルタイプでの設定
augroup("FileTypeSettings", { clear = true })
autocmd("FileType", {
  group = "FileTypeSettings",
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
  end,
  desc = "Enable wrap for markdown and text files",
})
