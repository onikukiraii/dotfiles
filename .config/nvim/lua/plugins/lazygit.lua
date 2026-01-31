-- toggleterm.nvim + lazygit（フロートウィンドウで起動）
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-g>", desc = "Open LazyGit (float)" },
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical terminal" },
    },
    config = function()
      local toggleterm = require("toggleterm")

      toggleterm.setup({
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        open_mapping = [[<C-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        persist_size = true,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
          width = function()
            return math.floor(vim.o.columns * 0.9)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.9)
          end,
        },
      })

      -- ターミナルモードでのキーマップ
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0 }
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

      -- LazyGit用のカスタムターミナル
      local Terminal = require("toggleterm.terminal").Terminal

      local lazygit = Terminal:new({
        cmd = "lazygit",
        dir = "git_dir",
        direction = "float",
        float_opts = {
          border = "curved",
          width = function()
            return math.floor(vim.o.columns * 0.95)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.95)
          end,
        },
        on_open = function(term)
          vim.cmd("startinsert!")
          -- lazygit内では Esc でターミナルモードを抜けないようにする
          vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
        end,
        on_close = function(_)
          vim.cmd("checktime") -- ファイル変更を検知してリロード
        end,
      })

      function _G.lazygit_toggle()
        lazygit:toggle()
      end

      -- Ctrl+g で LazyGit をフロートウィンドウで開く（Helixと同じ）
      vim.keymap.set("n", "<C-g>", "<cmd>lua lazygit_toggle()<cr>", { noremap = true, silent = true, desc = "Open LazyGit" })
      vim.keymap.set("n", "<leader>gg", "<cmd>lua lazygit_toggle()<cr>", { noremap = true, silent = true, desc = "Open LazyGit" })
    end,
  },
}
