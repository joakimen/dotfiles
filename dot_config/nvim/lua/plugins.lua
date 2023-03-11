local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
    autocmd BufWritePost plugins.lua source <afile> | PackerClean
    autocmd BufWritePost plugins.lua source <afile> | PackerInstall
  augroup end
]])

return require('packer').startup(function()

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  --- general purpose
  use { 'nvim-telescope/telescope.nvim', requires = { 'nvim-lua/plenary.nvim' }}
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'Mofiqul/dracula.nvim'
  use 'christoomey/vim-tmux-navigator'
  --use 'machakann/vim-sandwich'
  --use { 'lukas-reineke/indent-blankline.nvim', ft = {'yaml', 'json', 'toml'} }
  --use { 'andymass/vim-matchup', event = 'User ActuallyEditing' }
  use 'tommcdo/vim-lion'
  use 'scrooloose/nerdcommenter'

  -- git stuff
  use { 'lewis6991/gitsigns.nvim', config = function() require('gitsigns').setup() end }
  use { 'tpope/vim-fugitive', cmd = {'Git'} }
  use { 'TimUntersberger/neogit', requires = { 'nvim-lua/plenary.nvim' }, cmd = {'Neogit'} }

  use 'udalov/kotlin-vim'
  use 'nickeb96/fish.vim'

  --use {
    --'nvim-lualine/lualine.nvim',
    --requires = {'kyazdani42/nvim-web-devicons', opt = true},
  --}

  -- lang & linting
  --use { 'nvim-treesitter/nvim-treesitter', config = function() require 'config.treesitter' end, run = ':TSUpdate' }
  --use { 'neovim/nvim-lspconfig', config = function() require 'config.lsp' end }

  -- colorschemes
  --use {
    --'w0ng/vim-hybrid',
    --'freeo/vim-kalisi',
    --'jnurmine/Zenburn',
    --'morhetz/gruvbox',
    --'sickill/vim-monokai',
    --'tomasr/molokai',
    --'junegunn/seoul256.vim',
    --'joakimen/lena.vim',
    --'joshdick/onedark.vim',
  --}

  if packer_bootstrap then
    require('packer').sync()
  end
end)

