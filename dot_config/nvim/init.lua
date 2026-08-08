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
-- Two columns so diagnostics (sign priority 10) stop hiding gitsigns (6).
vim.opt.signcolumn = 'yes:2'
vim.opt.inccommand = 'split'
vim.opt.smoothscroll = true
vim.opt.scrolloff = 4
vim.opt.winborder = 'rounded'

-- Everything unfolded until asked otherwise. foldmethod/foldexpr are set per
-- buffer alongside treesitter, so buffers without a parser keep manual folds
-- and the startup buffer never pulls vim.treesitter in.
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

-- Keyed by lspconfig name so mason-lspconfig can both install and enable them.
-- The value is the server's `settings` block, empty where defaults suffice.
local servers = {
  bashls = {},
  clojure_lsp = {},
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
  jsonls = {},
  kotlin_language_server = {},
  lua_ls = {},
  terraformls = {},
  vtsls = {},
  yamlls = {},
  zls = {},
}

-- Everything else mason should keep installed: conform's formatters, plus the
-- tree-sitter CLI that nvim-treesitter's main branch shells out to for builds.
local tools = { 'gofumpt', 'goimports', 'prettierd', 'stylua', 'tree-sitter-cli' }

-- conform and nvim-treesitter resolve their binaries off PATH, so mason's bin
-- dir has to be there before either runs. Doing it here rather than relying on
-- mason.setup() keeps mason itself lazy.
vim.env.PATH = vim.fn.stdpath 'data' .. '/mason/bin' .. ':' .. vim.env.PATH

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
    'mason-org/mason.nvim',
    event = 'VeryLazy',
    config = function()
      require('mason').setup()

      -- mason-lspconfig covers the servers; nothing covers formatters or the
      -- tree-sitter CLI, so install any that are missing ourselves. Refreshing
      -- the registry can hit the network, so only do it when something is
      -- actually absent.
      local registry = require('mason-registry')
      local function install_missing()
        for _, name in ipairs(tools) do
          local ok, pkg = pcall(registry.get_package, name)
          if ok and not pkg:is_installed() then
            pkg:install()
          end
        end
      end

      local missing = vim.iter(tools):any(function(name)
        local ok, pkg = pcall(registry.get_package, name)
        return ok and not pkg:is_installed()
      end)
      if missing then
        registry.refresh(install_missing)
      end
    end,
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
    },
    config = function()
      for name, settings in pairs(servers) do
        vim.lsp.config(name, {
          settings = next(settings) and settings or nil,
        })
      end

      -- automatic_enable only enables servers that are actually installed, so
      -- a missing binary no longer errors on every matching buffer.
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true,
      }
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'mason-org/mason.nvim' },
    config = function()
      local ts = require('nvim-treesitter')
      local want = {
        'bash', 'clojure', 'diff', 'dockerfile', 'git_config', 'gitcommit',
        'go', 'gomod', 'gosum', 'gowork', 'hcl', 'javascript', 'json',
        'kotlin', 'lua', 'luadoc', 'make', 'markdown', 'markdown_inline',
        'query', 'terraform', 'toml', 'tsx', 'typescript', 'vim', 'vimdoc',
        'yaml', 'zig',
      }

      local installed = {}
      for _, lang in ipairs(ts.get_installed()) do
        installed[lang] = true
      end
      local missing = vim.tbl_filter(function(lang) return not installed[lang] end, want)
      if #missing > 0 then
        if vim.fn.executable('tree-sitter') == 1 then
          ts.install(missing)
        else
          vim.notify(
            'tree-sitter CLI not on PATH yet; parsers install on next launch',
            vim.log.levels.WARN
          )
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('UserTreesitter', { clear = true }),
        callback = function(ev)
          if not pcall(vim.treesitter.start, ev.buf) then
            return
          end
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.wo[0][0].foldmethod = 'expr'
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end,
        desc = 'Enable treesitter highlighting, indent and folds where a parser exists',
      })
    end,
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
    -- blink's plugin file already registers its capabilities via
    -- vim.lsp.config('*'), so servers need no capabilities wiring here.
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
            -- Negative so an exact LSP symbol match outranks a Copilot guess.
            score_offset = -3,
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
    opts = {
      -- Auto-detection rescans the plugin list on every startup (~3.6ms).
      -- These are exactly what it detected; treesitter and native_lsp are on
      -- by default and stay that way.
      auto_integrations = false,
      integrations = {
        blink_cmp = true,
        fzf = true,
        gitsigns = true,
        lsp_trouble = true,
        mason = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  {
    'ibhagwan/fzf-lua',
    cmd = 'FzfLua',
    opts = {
      'default',
      winopts = { preview = { default = 'bat' } },
    },
    keys = {
      { '<leader>f', function() require('fzf-lua').files() end, desc = 'Open file' },
      { '<leader>b', function() require('fzf-lua').buffers() end, desc = 'Open buffer' },
      { '<leader>/', function() require('fzf-lua').blines() end, desc = 'Search in buffer' },
      { '<leader>k', function() require('fzf-lua').live_grep() end, desc = 'Grep workspace' },
      { '<leader>gf', function() require('fzf-lua').git_files() end, desc = 'Git files' },
      { '<leader>gs', function() require('fzf-lua').git_status() end, desc = 'Git status' },
      { '<leader>gl', function() require('fzf-lua').git_commits() end, desc = 'Git log (repo)' },
      { '<leader>gL', function() require('fzf-lua').git_bcommits() end, desc = 'Git log (buffer)' },
      { '<leader>gb', function() require('fzf-lua').git_branches() end, desc = 'Git branches' },
      { '<leader>sd', function() require('fzf-lua').diagnostics_workspace() end, desc = 'Diagnostics' },
      { '<leader>sh', function() require('fzf-lua').helptags() end, desc = 'Help' },
      { '<leader>sr', function() require('fzf-lua').resume() end, desc = 'Resume last search' },
      { '<leader>sk', function() require('fzf-lua').keymaps() end, desc = 'Keymaps' },
      { '<leader>so', function() require('fzf-lua').oldfiles() end, desc = 'Recent files' },
      { '<leader>sc', function() require('fzf-lua').command_history() end, desc = 'Command history' },
      { '<leader>sw', function() require('fzf-lua').grep_cword() end, desc = 'Grep word under cursor' },
    },
  },

  {
    'stevearc/conform.nvim',
    cmd = 'ConformInfo',
    -- Formatting is always explicit: no format_on_save, so a surgical edit in a
    -- shared codebase never drags unrelated reformatting along with it.
    -- <leader>cf lives with the other keymaps; requiring conform loads it.
    opts = {
      formatters_by_ft = {
        -- go is intentionally absent: gopls already has gofumpt = true, and
        -- formatting in-process costs ~0.5ms against ~47ms for goimports +
        -- gofumpt as subprocesses. Format_buffer() runs organizeImports first,
        -- so the result is identical.
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
    },
  },

  -- UI enhancements
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local b = vim.keymap.set
        b('n', ']h', function() gs.nav_hunk('next') end, { buffer = bufnr, desc = 'Next hunk' })
        b('n', '[h', function() gs.nav_hunk('prev') end, { buffer = bufnr, desc = 'Prev hunk' })
        b('n', '<leader>hs', gs.stage_hunk, { buffer = bufnr, desc = 'Stage/unstage hunk' })
        b('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { buffer = bufnr, desc = 'Stage/unstage selection' })
        b('n', '<leader>hr', gs.reset_hunk, { buffer = bufnr, desc = 'Reset hunk' })
        b('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
          { buffer = bufnr, desc = 'Reset selection' })
        b('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr, desc = 'Preview hunk' })
        b('n', '<leader>hb', function() gs.blame_line({ full = true }) end, { buffer = bufnr, desc = 'Blame line' })
      end,
    },
  },
  { 'folke/which-key.nvim', event = 'VeryLazy' },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'catppuccin-mocha',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        -- vim.lsp.status() is built into 0.12, so server progress (gopls
        -- indexing, say) is visible without a notification plugin.
        lualine_c = { 'filename', { vim.lsp.status, separator = '' } },
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
-- zv opens the fold the match landed in, which matters now that folding is on.
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Center on next match' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Center on prev match' })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })
vim.keymap.set('i', 'fd', '<Esc>', { desc = 'Escape' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })

--- Apply every `source.organizeImports` action the attached servers offer.
--- Synchronous so it always lands before formatting rewrites the same ranges.
local function organize_imports(bufnr, timeout_ms)
  local clients = vim.lsp.get_clients { bufnr = bufnr, method = 'textDocument/codeAction' }
  for _, client in ipairs(clients) do
    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.context = { only = { 'source.organizeImports' }, diagnostics = {} }

    local responses = client:request_sync('textDocument/codeAction', params, timeout_ms, bufnr)
    for _, action in pairs(responses and responses.result or {}) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
      end
    end
  end
end

--- Organize imports, then format. conform handles filetypes with a configured
--- formatter and falls back to the LSP for the rest.
local function format_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  organize_imports(bufnr, 2000)
  require('conform').format { bufnr = bufnr, lsp_format = 'fallback', timeout_ms = 5000 }
end

vim.keymap.set('n', '<leader>cf', format_buffer, { desc = 'Format buffer' })

--- Replace the buffer with `jq`-formatted JSON, leaving it untouched on error.
local function format_json()
  if vim.fn.executable('jq') == 0 then
    vim.notify('jq is not installed', vim.log.levels.ERROR)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local view = vim.fn.winsaveview()
  vim.system({ 'jq', '.' }, { stdin = lines, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(vim.trim(result.stderr or 'jq failed'), vim.log.levels.ERROR)
        return
      end
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(vim.trim(result.stdout), '\n'))
      vim.fn.winrestview(view)
    end)
  end)
end

vim.keymap.set('n', '<leader>tj', format_json, { desc = 'Format JSON' })

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
  -- Full text on the line under the cursor only; everywhere else the sign
  -- column carries the signal. Far quieter than virtual_text on every line.
  virtual_text = false,
  virtual_lines = { current_line = true },
  float = { style = 'minimal' },
}

-- Autocommands
local augroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(ev)
    local bufnr = ev.buf
    local fzf = function(picker)
      return function() require('fzf-lua')[picker]() end
    end
    vim.keymap.set('n', 'gd', fzf('lsp_definitions'), { buffer = bufnr, desc = 'Goto definition' })
    vim.keymap.set('n', 'grr', fzf('lsp_references'), { buffer = bufnr, desc = 'Goto references' })
    vim.keymap.set('n', 'gri', fzf('lsp_implementations'), { buffer = bufnr, desc = 'Goto implementation' })
    vim.keymap.set('n', 'grt', fzf('lsp_typedefs'), { buffer = bufnr, desc = 'Goto type definition' })
    vim.keymap.set('n', '<leader>ss', fzf('lsp_document_symbols'), { buffer = bufnr, desc = 'Document symbols' })
    vim.keymap.set('n', '<leader>sS', fzf('lsp_live_workspace_symbols'),
      { buffer = bufnr, desc = 'Workspace symbols' })

    -- Off by default: useful on demand, too noisy while typing.
    vim.keymap.set('n', '<leader>ch', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }, { bufnr = bufnr })
    end, { buffer = bufnr, desc = 'Toggle inlay hints' })
  end,
})

-- Restore the last cursor position, except where starting at the top is correct.
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  callback = function(ev)
    local skip = { gitcommit = true, gitrebase = true, gitconfig = true }
    if skip[vim.bo[ev.buf].filetype] then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      vim.cmd('normal! zv')
    end
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- which-key setup
vim.api.nvim_create_autocmd('User', {
  group = augroup,
  pattern = 'VeryLazy',
  callback = function()
    local wk = require('which-key')
    wk.setup {
      preset = 'helix',
      delay = 0,
    }

    wk.add {
      { '<leader>c', group = 'LSP' },
      { '<leader>g', group = 'Git' },
      { '<leader>h', group = 'Git hunks' },
      { '<leader>s', group = 'Search' },
      { '<leader>t', group = 'Text' },
      { '<leader>x', group = 'Diagnostics' },
    }
  end,
})
