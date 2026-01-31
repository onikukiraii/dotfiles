-- Treesitter: シンタックスハイライト (nvim 0.11+)
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      -- nvim-treesitter の runtime ディレクトリを runtimepath に追加
      local ts_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/runtime"
      if vim.fn.isdirectory(ts_path) == 1 then
        vim.opt.runtimepath:append(ts_path)
      end

      require("nvim-treesitter").setup({
        ensure_installed = {
          "python",
          "lua",
          "javascript",
          "typescript",
          "tsx",
          "html",
          "css",
          "json",
          "yaml",
          "toml",
          "markdown",
          "markdown_inline",
          "bash",
          "vim",
          "vimdoc",
        },
        auto_install = true,
      })

      -- treesitter ハイライトを自動有効化
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft
          -- パーサーが存在するか確認してから有効化
          local ok = pcall(vim.treesitter.start, args.buf, lang)
          if ok then
            -- vim syntax を無効化（treesitter と競合するため）
            vim.bo[args.buf].syntax = ""
          end
        end,
      })
    end,
  },
}
