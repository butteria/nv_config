return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  -- {
  --   "3rd/image.nvim",
  -- },
  -- Awesome jupyter notebook in neovim
  -- {
  --   "benlubas/molten-nvim",
  --   config = function()
  --     vim.cmd('runtime! plugin/rplugin.vim')
  --     vim.g.python3_host_prog=vim.fn.expand("$HOME/.virtualenvs/neovim/bin/python3")
  --   end,
  --   lazy = false,
  -- },
  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
