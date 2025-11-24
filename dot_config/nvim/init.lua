vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Core settings
vim.opt.clipboard = 'unnamedplus'
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.completeopt = 'menuone,noselect'
vim.opt.termguicolors = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.splitright = true
vim.opt.mouse = 'a'
vim.wo.number = true
vim.wo.signcolumn = 'yes'

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
require('lazy').setup({
  -- Language servers and completion
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
  },
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
  },

  -- Color scheme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  -- Copilot
  'github/copilot.vim',

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    tag = 'v0.1.9',
    dependencies = 'nvim-lua/plenary.nvim',
  },

  -- UI enhancements
  'numToStr/Comment.nvim',
  'lewis6991/gitsigns.nvim',
  'folke/which-key.nvim',
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'catppuccin-mocha',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
})

-- Keymaps
local function keymap(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Navigation
keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
keymap('n', 'n', 'nzz', { desc = 'Center on next match' })
keymap('n', 'N', 'Nzz', { desc = 'Center on prev match' })

-- Utilities
keymap('n', '<leader>j', ':setf json|%!jq<CR>', { desc = 'Format JSON' })
keymap('i', 'fd', '<Esc>', { desc = 'Escape' })

-- Telescope (Helix-style keybindings)
keymap('n', '<leader>f', require('telescope.builtin').find_files, { desc = 'Open file' })
keymap('n', '<leader>b', require('telescope.builtin').buffers, { desc = 'Open buffer' })
keymap('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find()
end, { desc = 'Search in buffer' })
keymap('n', '<leader>k', require('telescope.builtin').live_grep, { desc = 'Grep workspace' })

-- LSP setup
local servers = {
  clojure_lsp = {},
  ts_ls = {},
  gopls = {},
  bashls = {},
  yamlls = {},
  jsonls = {},
  terraformls = {},
  kotlin_language_server = {},
  lua_ls = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = {
          'vim',
          'require'
        },
      },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local on_attach = function(_, bufnr)
  local b = vim.keymap.set
  b('n', 'gd', require('telescope.builtin').lsp_definitions, { buffer = bufnr, desc = '[G]oto [D]efinition' })
  b('n', 'gr', require('telescope.builtin').lsp_references, { buffer = bufnr, desc = '[G]oto [R]eferences' })
  b('n', 'gi', require('telescope.builtin').lsp_implementations, { buffer = bufnr, desc = '[G]oto [I]mplementation' })
  b('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = 'Hover' })
  b('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr, desc = '[R]e[n]ame' })
  b('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = '[C]ode [A]ction' })
  b('n', '<leader><leader>f', vim.lsp.buf.format, { buffer = bufnr, desc = '[F]ormat' })
end

require('mason').setup()

for server_name, config_opts in pairs(servers) do
  vim.lsp.config(server_name, {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = config_opts ~= {} and config_opts or nil,
  })
end

require('mason-lspconfig').setup {
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = true,
}

-- Completion
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- Treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'clojure', 'typescript', 'go', 'bash', 'yaml', 'json',
    'terraform', 'hcl', 'lua', 'vim', 'markdown', 'markdown_inline'
  },
  auto_install = false,
  highlight = { enable = true },
  indent = { enable = true },
  modules = {},
  ignore_install = {},
  sync_install = false,
  parser_install_dir = nil,
}

-- Diagnostics
vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN] = '▲',
      [vim.diagnostic.severity.INFO] = '●',
      [vim.diagnostic.severity.HINT] = '◆',
    },
  },
  float = {
    border = 'rounded',
    style = 'minimal',
  },
}

-- Diagnostic navigation with hover
keymap('n', '[d', function()
  vim.diagnostic.goto_prev()
  vim.diagnostic.open_float(nil, { focusable = false, header = false })
end, { desc = 'Previous diagnostic' })

keymap('n', ']d', function()
  vim.diagnostic.goto_next()
  vim.diagnostic.open_float(nil, { focusable = false, header = false })
end, { desc = 'Next diagnostic' })

-- which-key setup with keybind mappings
local wk = require('which-key')
wk.setup {
  preset = 'modern',
  delay = 0,
}

wk.add {
  -- LSP mappings
  { '<leader>c',  group = 'LSP' },
  { '<leader>ca', vim.lsp.buf.code_action,                  desc = 'Code action' },
  { '<leader>cf', vim.lsp.buf.format,                       desc = 'Format code' },
  { '<leader>cr', vim.lsp.buf.rename,                       desc = 'Rename symbol' },
  { '<leader>ci', vim.lsp.buf.implementation,               desc = 'Goto implementation' },
  { '<leader>ck', vim.lsp.buf.hover,                        desc = 'Hover' },
  { '<leader>cd', vim.lsp.buf.definition,                   desc = 'Goto definition' },
  { '<leader>cD', vim.lsp.buf.references,                   desc = 'Find references' },

  -- Diagnostics
  { '<leader>d',  group = 'Diagnostics' },
  { '<leader>dd', vim.diagnostic.open_float,                desc = 'Show diagnostic' },
  { '<leader>dq', vim.diagnostic.setloclist,                desc = 'Add diagnostics to loclist' },

  -- File/Buffer navigation (already mapped but for display)
  { '<leader>f',  desc = 'Open file' },
  { '<leader>b',  desc = 'Open buffer' },
  { '<leader>/',  desc = 'Search in buffer' },
  { '<leader>k',  desc = 'Grep workspace' },

  -- Telescope helpers
  { '<leader>g',  group = 'Git/Grep' },
  { '<leader>gf', require('telescope.builtin').git_files,   desc = 'Git files' },

  -- Search enhancements
  { '<leader>s',  group = 'Search' },
  { '<leader>sd', require('telescope.builtin').diagnostics, desc = 'Diagnostics' },
  { '<leader>sh', require('telescope.builtin').help_tags,   desc = 'Help' },
  { '<leader>sr', require('telescope.builtin').resume,      desc = 'Resume last search' },

  -- Text manipulation
  { '<leader>t',  group = 'Text' },
  { '<leader>tj', ':setf json|%!jq<CR>',                    desc = 'Format JSON' },
}

-- Copilot
vim.g.copilot_filetypes = {
  markdown = false,
}

-- Autocommands
local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

-- Restore cursor position
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = augroup,
  command = 'silent! normal! g`"zv',
})

-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})
