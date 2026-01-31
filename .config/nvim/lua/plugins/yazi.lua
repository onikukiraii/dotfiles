-- yazi.nvim - ファイルマネージャー（Helixと同じ Ctrl+y で起動）
return {
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<C-y>",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at current file",
      },
      {
        "<leader>fy",
        "<cmd>Yazi cwd<cr>",
        desc = "Open yazi in working directory",
      },
      {
        "<leader>yt",
        "<cmd>Yazi toggle<cr>",
        desc = "Toggle yazi (resume last session)",
      },
    },
    opts = {
      open_for_directories = true,
      keymaps = {
        show_help = "<f1>",
      },
    },
  },
}
