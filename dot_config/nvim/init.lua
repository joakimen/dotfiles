require('plugins')
require('config.telescope')
require('telescope').load_extension('fzf')
--require('config.lualine')

-- opts
local o = vim.opt
local g = vim.g
local viml = vim.api.nvim_command

o.updatetime = 300
o.number = true
o.showmatch = true
o.lazyredraw = true
o.clipboard = 'unnamedplus'
o.splitright = true
o.splitbelow = true
o.expandtab = true
o.shiftround = true
o.ignorecase = true
o.smartcase = true
o.gdefault = true
o.list = true
o.swapfile = false
o.undofile = true
o.virtualedit = 'block'
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2
o.completeopt = 'menuone,preview'
o.formatoptions = o.formatoptions + "qrn1j"
o.previewheight = 25
o.undodir = '/tmp//,.'
o.wildmode = { "longest", "list", "full" }
o.wildignore = o.wildignore + { "*.o", "*~", "*.pyc", "*pycache*" }
o.foldlevelstart = 0
o.cmdheight = 2
o.modelines = 2
o.inccommand = 'split'
viml [[set listchars=tab:▸\ ,]]

-- keymaps
function map(mode, key_seq, cmd)
    vim.api.nvim_set_keymap(mode, key_seq, cmd, { noremap = true, silent = true })
end

function nmap(key_seq, cmd) map('n', key_seq, cmd) end
function imap(key_seq, cmd) map('i', key_seq, cmd) end
function vmap(key_seq, cmd) map('v', key_seq, cmd) end
function xmap(key_seq, cmd) map('x', key_seq, cmd) end

-- leader
map('', '<Space>', '<nop>')
vim.g.mapleader = ' '

-- fatfingerfix
nmap('q:', '<nop>')
nmap('Q', '<nop>')

-- move "virtually" across wrapped lines
nmap('j', 'gj')
nmap('k', 'gk')
xmap('j', 'gj')
xmap('k', 'gk')

-- kill buffers
nmap('<leader>d', ':bd<CR>')
nmap('<leader>D', ':bd!<CR>')

-- open vimrc
nmap('<leader>v', ':e $MYVIMRC<CR>')

-- fd = esc
imap('fd', '<Esc>')

-- telescope
nmap('<C-f>', ':Telescope find_files<CR>')
nmap('<C-g>', ':Telescope live_grep<CR>')
nmap('<C-b>', ':Telescope buffers<CR>')
nmap('<C-s>', ':Telescope current_buffer_fuzzy_find<CR>')
nmap('<C-c>', ':Telescope colorscheme<CR>')

-- comments
nmap('cm', ':call nerdcommenter#Comment(0, "toggle")<CR>')
vmap('cm', ':call nerdcommenter#Comment(0, "toggle")<CR>')

-- misc
nmap('<c-s>', ':w<CR>')
nmap('<leader>j', ':setf json|%!jq<cr>')
nmap('<leader>w', ':lua cleanup_whitespace()<CR>')
nmap('<leader>l', ':nohlsearch<cr>')
nmap('n', 'nzz')
nmap('N', 'Nzz')

-- ci-patching
nmap('ci(', '%ci(')
nmap('ci)', '%ci)')
nmap('ci[', '%ci[')
nmap('ci]', '%ci]')
nmap('ci{', '%ci{')
nmap('ci}', '%ci}')

-- git
nmap('gb', ':Git blame<cr>')
nmap('gs', ':Neogit<cr>')

viml [[colorscheme dracula]]

-- show trailing whitespace
viml([[
hi ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
]])

-- convenience-func to register augroups
function nvim_create_augroups(definitions)
    for group_name, definition in pairs(definitions) do
        viml('augroup '..group_name)
        viml('autocmd!')
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
            viml(command)
        end
        viml('augroup END')
    end
end

function cleanup_whitespace()
  viml '%s/\\v\\s+$//e'
  viml 'retab'
end

nvim_create_augroups({
  reload_vimrc = {
    {"BufWritePost",[[$MYVIMRC nested source $MYVIMRC | redraw]]};
  };
  restore_cursor = {
    { 'BufRead', '*', [[call setpos(".", getpos("'\""))]] };
  };
})
