-- フォーマッター設定（conform.nvim - prettier/ruff対応）
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        -- JavaScript/TypeScript
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },

        -- Vue
        vue = { "prettier" },

        -- Web
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },

        -- Python（Helixと同じくruffを使用）
        python = { "ruff_format" },

        -- Lua
        lua = { "stylua" },
      },

      -- 保存時に自動フォーマット（Helixのauto-formatと同等）
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },

      -- フォーマッター設定
      formatters = {
        prettier = {
          prepend_args = { "--single-quote", "--trailing-comma", "es5" },
        },
      },
    },
  },

  -- mason-tool-installer: フォーマッター/リンターのインストール
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettier",
          "stylua",
          "ruff",
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
}
