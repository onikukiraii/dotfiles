-- テーマ設定（github-nvim-theme）
return {
  {
    "projekt0n/github-nvim-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = {
          transparent = true,
          terminal_colors = true,
          styles = {
            comments = "italic",
            keywords = "bold",
          },
        },
      })
      -- github_dark / github_dark_dimmed / github_dark_high_contrast
      -- github_light / github_light_high_contrast
      vim.cmd.colorscheme("github_dark")
    end,
  },
  -- 以前のテーマ（catppuccin）- 戻したい場合用
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     require("catppuccin").setup({
  --       flavour = "mocha",
  --       transparent_background = true,
  --       term_colors = true,
  --       integrations = {
  --         cmp = true,
  --         gitsigns = true,
  --         treesitter = true,
  --         telescope = { enabled = true },
  --         mason = true,
  --         native_lsp = { enabled = true },
  --       },
  --     })
  --     vim.cmd.colorscheme("catppuccin-mocha")
  --   end,
  -- },
}
