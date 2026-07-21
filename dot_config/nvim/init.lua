vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Core settings
vim.opt.clipboard = 'unnamedplus'
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.signcolumn = 'yes'
vim.opt.inccommand = 'split'
vim.opt.smoothscroll = true

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

require('lazy').setup({
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
    },
  },
  {
    'gpanders/nvim-parinfer',
    ft = 'clojure',
    config = function()
      vim.g.parinfer_force_balance = true
    end,
  },
  {
    'saghen/blink.cmp',
    version = '1.*',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'fang2hou/blink-copilot',
    },
    opts = {
      keymap = {
        preset = 'default',
        ['<Tab>'] = { 'snippet_forward', 'select_and_accept', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'fallback' },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
        documentation = { auto_show = true },
      },
      signature = { enabled = true },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'copilot' },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-copilot',
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = false,
      },
    },
  },


  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      require('telescope').load_extension('fzf')
    end,
  },

  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
      formatters_by_ft = {
        go = { 'goimports', 'gofumpt' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
        yaml = { 'prettierd', 'prettier', stop_after_first = true },
        lua = { 'stylua' },
        terraform = { 'terraform_fmt' },
        tf = { 'terraform_fmt' },
        ['terraform-vars'] = { 'terraform_fmt' },
      },
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        local no_auto = { typescript = true, typescriptreact = true, javascript = true, javascriptreact = true }
        if no_auto[ft] then return end
        return { timeout_ms = 1000, lsp_format = 'fallback' }
      end,
    },
  },

  -- UI enhancements
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local b = vim.keymap.set
        b('n', ']h', function() gs.nav_hunk('next') end, { buffer = bufnr, desc = 'Next hunk' })
        b('n', '[h', function() gs.nav_hunk('prev') end, { buffer = bufnr, desc = 'Prev hunk' })
        b('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = 'Stage hunk' })
        b('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { buffer = bufnr, desc = 'Stage selection' })
        b('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = 'Reset hunk' })
        b('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { buffer = bufnr, desc = 'Reset selection' })
        b('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr, desc = 'Undo stage hunk' })
        b('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview hunk' })
        b('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { buffer = bufnr, desc = 'Blame line' })
      end,
    },
  },
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
  {
    'folke/trouble.nvim',
    opts = {},
    cmd = 'Trouble',
    keys = {
      {
        '<leader>xx',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Diagnostics (Trouble)',
      },
      {
        '<leader>xX',
        '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
        desc = 'Buffer Diagnostics (Trouble)',
      },
    },
  },
})

-- Keymaps
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'n', 'nzz', { desc = 'Center on next match' })
vim.keymap.set('n', 'N', 'Nzz', { desc = 'Center on prev match' })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
vim.keymap.set('i', 'fd', '<Esc>', { desc = 'Escape' })

-- Telescope keymaps
vim.keymap.set('n', '<leader>f', function() require('telescope.builtin').find_files() end, { desc = 'Open file' })
vim.keymap.set('n', '<leader>b', function() require('telescope.builtin').buffers() end, { desc = 'Open buffer' })
vim.keymap.set('n', '<leader>/', function() require('telescope.builtin').current_buffer_fuzzy_find() end,
  { desc = 'Search in buffer' })
vim.keymap.set('n', '<leader>k', function() require('telescope.builtin').live_grep() end, { desc = 'Grep workspace' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })

-- LSP servers
local servers = {
  clojure_lsp = {},
  vtsls = {},
  gopls = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      analyses = {
        unusedparams = true,
        shadow = true,
      },
    },
  },
  bashls = {},
  yamlls = {},
  jsonls = {},
  terraformls = {},
  kotlin_language_server = {},
  zls = {},
  lua_ls = {},
}

local capabilities = require('blink.cmp').get_lsp_capabilities()

require('mason').setup()

for server_name, config_opts in pairs(servers) do
  vim.lsp.config(server_name, {
    capabilities = capabilities,
    settings = next(config_opts) and config_opts or nil,
  })
end

vim.lsp.enable(vim.tbl_keys(servers))

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
  virtual_text = { spacing = 4, prefix = '●' },
  float = {
    border = 'rounded',
    style = 'minimal',
  },
}

-- Autocommands
local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(ev)
    local bufnr = ev.buf
    local tb = require('telescope.builtin')
    vim.keymap.set('n', 'gd', tb.lsp_definitions, { buffer = bufnr, desc = 'Goto definition' })
    vim.keymap.set('n', 'grr', tb.lsp_references, { buffer = bufnr, desc = 'Goto references' })
    vim.keymap.set('n', 'gri', tb.lsp_implementations, { buffer = bufnr, desc = 'Goto implementation' })
    vim.keymap.set('n', 'gy', tb.lsp_type_definitions, { buffer = bufnr, desc = 'Goto type definition' })
    vim.keymap.set('n', '<leader>cf',
      function() require('conform').format({ bufnr = bufnr, lsp_format = 'fallback' }) end,
      { buffer = bufnr, desc = 'Format code' })
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  group = augroup,
  command = 'silent! normal! g`"zv',
})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- which-key setup
local wk = require('which-key')
wk.setup {
  preset = 'helix',
  delay = 0,
}

wk.add {
  { '<leader>c',  group = 'LSP' },

  { '<leader>f',  desc = 'Open file' },
  { '<leader>b',  desc = 'Open buffer' },
  { '<leader>/',  desc = 'Search in buffer' },
  { '<leader>k',  desc = 'Grep workspace' },

  { '<leader>h',  group = 'Git hunks' },
  { '<leader>g',  group = 'Git/Grep' },
  { '<leader>gf', function() require('telescope.builtin').git_files() end,   desc = 'Git files' },

  { '<leader>s',  group = 'Search' },
  { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = 'Diagnostics' },
  { '<leader>sh', function() require('telescope.builtin').help_tags() end,   desc = 'Help' },
  { '<leader>sr', function() require('telescope.builtin').resume() end,      desc = 'Resume last search' },

  { '<leader>t',  group = 'Text' },
  { '<leader>tj', function()
    if vim.fn.executable('jq') == 0 then
      vim.notify('jq is not installed', vim.log.levels.ERROR)
      return
    end
    local ok, _ = pcall(vim.cmd, '%!jq')
    if not ok then
      vim.cmd('undo')
      vim.notify('Buffer is not valid JSON', vim.log.levels.ERROR)
    end
  end, desc = 'Format JSON' },
}
