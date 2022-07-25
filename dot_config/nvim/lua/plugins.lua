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
  use 'machakann/vim-sandwich'
  use { 'andymass/vim-matchup', event = 'User ActuallyEditing' }
  use { 'nvim-telescope/telescope.nvim', requires = { {'nvim-lua/plenary.nvim'} } }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use { 'lukas-reineke/indent-blankline.nvim', ft = {'yaml', 'json', 'toml'} }
  use {

    'nvim-lualine/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
    config = [[require('config.lualine')]]
    --config = [[require('lualine').setup()]]
  }

  use 'tommcdo/vim-lion'
  use 'scrooloose/nerdcommenter'

  --- lang specific. trash when lsp confed?
  use 'vim-scripts/VisIncr'
  use 'mustache/vim-mustache-handlebars'
  use 'hashivim/vim-vagrant'
  use 'cespare/vim-toml'
  use 'Glench/Vim-Jinja2-Syntax'
  use 'NoahTheDuke/vim-just'
  use 'SidOfc/mkdx'

  -- git stuff
  use { 'lewis6991/gitsigns.nvim', config = [[require('gitsigns').setup()]] }
  use 'tpope/vim-fugitive'

  -- lang & linting
  use { 'nvim-treesitter/nvim-treesitter', config = [[require ('config.treesitter')]], run = ':TSUpdate' }
  use 'kyazdani42/nvim-web-devicons'
  use { 'neovim/nvim-lspconfig', config = [[require('config.lsp')]] }
  use {
    'nvim-treesitter/playground',
    'folke/trouble.nvim',
    'kosayoda/nvim-lightbulb',
  }

  -- colorschemes
  use {
    'romainl/apprentice',
    'w0ng/vim-hybrid',
    'freeo/vim-kalisi',
    'jnurmine/Zenburn',
    'morhetz/gruvbox',
    'sickill/vim-monokai',
    'tomasr/molokai',
    'junegunn/seoul256.vim',
    'joakimen/lena.vim',
    'joshdick/onedark.vim',
    'Mofiqul/dracula.nvim'
  }

  use 'christoomey/vim-tmux-navigator'

  if packer_bootstrap then
    require('packer').sync()
  end
end)

