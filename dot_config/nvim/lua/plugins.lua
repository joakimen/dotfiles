local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' }, tag = '0.1.2', lazy = true },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
  'christoomey/vim-tmux-navigator',
  'machakann/vim-sandwich',
  'tommcdo/vim-lion',
  'scrooloose/nerdcommenter',
  'lewis6991/gitsigns.nvim',
  { 'tpope/vim-fugitive', cmd = {'Git'} },
  { 'TimUntersberger/neogit', dependencies = { 'nvim-lua/plenary.nvim' }, cmd = {'Neogit'} },
  { 'nvim-lualine/lualine.nvim', dependencies = {'kyazdani42/nvim-web-devicons'} },

  -- lang & linting
  { 'nvim-treesitter/nvim-treesitter', config = function() require 'config.treesitter' end, build = ':TSUpdate' },
  { 'neovim/nvim-lspconfig', config = function() require 'config.lsp' end },
  -- clojure
  { "Olical/conjure",
    ft = { "clojure", "fennel" },
    config = function()
      vim.api.nvim_create_autocmd("BufNewFile", {
        group = vim.api.nvim_create_augroup("conjure_log_disable_lsp", { clear = true }),
        pattern = { "conjure-log-*" },
        callback = function(event)
          vim.diagnostic.disable(event.buf)
        end,
        desc = "Conjure Log disable LSP diagnostics",
      })
    end,
  },
  { "gpanders/nvim-parinfer",
    ft = { "clojure", "fennel" },
    config = function()
      vim.g.parinfer_force_balance = true
    end,
  },

  -- colorschemes
  'Mofiqul/dracula.nvim', -- active theme, no lazy
  { 'jnurmine/Zenburn', lazy = true },
  { 'joakimen/lena.vim', lazy = true },
  { 'junegunn/seoul256.vim', lazy = true },
  { 'junegunn/seoul256.vim', lazy = true }


})
