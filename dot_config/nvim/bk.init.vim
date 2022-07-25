" =============================================================================
" init.vim
" Author: Joakim Engeset <joakim.engeset@gmail.com>
" =============================================================================
inoremap fd <Esc>
let mapleader = ' '

lua require('plugins')
lua require('telescope').load_extension('fzf')

set updatetime=300

" options ----------------------------------------------------------------- {{{
set number
set lazyredraw
set clipboard+=unnamedplus
set nrformats=
set splitright
set splitbelow
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set shiftround
set ignorecase
set smartcase
set gdefault
set noswapfile
set virtualedit=block
set listchars=tab:▸\ ,
set list
set completeopt=menuone,preview
set formatoptions+=qrn1j
set previewheight=25
set undofile
set undodir=/tmp//,.
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe
set foldlevelstart=0
set cmdheight=2
set modelines=2
set inccommand=split

" }}}
" colors ------------------------------------------------------------------ {{{

colo desert

"hi normal ctermbg=none
"hi nontext ctermbg=none
hi ExtraWhitespace ctermbg=red guibg=red
hi Search cterm=NONE ctermfg=lightgrey ctermbg=blue
match ExtraWhitespace /\s\+$/

" }}}
" abbreviations ----------------------------------------------------------- {{{

" display help in vertical split
cabbrev h vert h

" }}}
" keybindings ------------------------------------------------------------- {{{

" json: format buffer with jq
nnoremap <leader>j :setf json\|%!jq<cr>

" move as expected across wrapped lines
nnoremap j gj
nnoremap k gk
xnoremap j gj
xnoremap k gk

" window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" disable command-history
nnoremap q: <nop>
nnoremap Q <nop>

" toggle fold
nnoremap , za

" toggle all folds using &foldlevel
nnoremap <silent><BS> :exec 'setlocal foldlevel='. (&foldlevel > 0 ? 0: 10)<CR>

" google word under cursor
nnoremap <leader>? :call <SID>google(expand("<cWORD>"))<cr>

" Remove tabs and trailing whitespace
nnoremap <silent> <Leader>w :call CleanupWhitespace()<CR>

" diff-keybinds
nnoremap dp :diffput<CR>
nnoremap dg :diffget<CR>

" Make S-y work like S-d
nnoremap <S-y> y$

" insert-mode paste
inoremap <C-v> <C-r>+

" disable Ex mode shortcut
nnoremap <S-q> <Nop>

" redraw screen when fucked
nnoremap <silent> U :syntax sync fromstart<cr>:redraw!<CR>

" Clear last search result
nnoremap <silent> <leader>l :nohlsearch<CR>

" When navigating between search results, center screen
nnoremap n nzz
nnoremap N Nzz

" Close buffer
nnoremap <silent> <leader>d :bd<CR>

" ci patching
cnoreabbrev ci( %ci(
cnoreabbrev ci) %ci)
cnoreabbrev ci[ %ci[
cnoreabbrev ci] %ci]
cnoreabbrev ci{ %ci{
cnoreabbrev ci} %ci}

" terminal: navigation
tnoremap <C-h> <C-\><C-N><C-w>h
tnoremap <C-j> <C-\><C-N><C-w>j
tnoremap <C-k> <C-\><C-N><C-w>k
tnoremap <C-l> <C-\><C-N><C-w>l

" terminal: escape
tnoremap fd <C-\><C-n>
tnoremap <Esc> <C-\><C-n>
tnoremap fd <C-\><C-n>

" terminal: open in buffer/hsplit/vsplit
nnoremap <silent> <leader>t :te<CR>
nnoremap <silent> <leader>v :vs $MYVIMRC<CR>

" }}}
" plugin keybindings ------------------------------------------------------ {{{

" telescope.nvim
nnoremap <silent> <C-f> :Telescope find_files<CR>
nnoremap <silent> <C-g> :Telescope live_grep<CR>
nnoremap <silent> <C-b> :Telescope buffers<CR>
nnoremap <silent> <C-s> :Telescope grep_string<CR>
nnoremap <silent> <C-c> :Telescope colorscheme<CR>

" fugitive.vim
nnoremap gs :Git<CR>
nnoremap gb :Git blame<CR>

" NERDComment
nnoremap <silent> cm :call nerdcommenter#Comment(0, "toggle")<CR>
vnoremap <silent> cm :call nerdcommenter#Comment(0, "toggle")<CR>

" }}}
" functions --------------------------------------------------------------- {{{

function! CleanupWhitespace()
  " remove trailing whitespace
  %s/\v\s+$//e
  retab
endfunction

" }}}
" autocommands ------------------------------------------------------------ {{{

" general {{{

augroup general
  au!
  " assume last known position of file
  au BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif

  " make autoread behave like expected
  au FocusGained * :checktime

augroup end

" highlight unwanted whitespace
augroup format_whitespace
  au!
  au BufNewFile,BufRead,InsertLeave * silent! match ExtraWhitespace /\s\+$/
  au InsertEnter * silent! match ExtraWhitespace /\s\+\%#\@<!$/
augroup end

" wrap text in quickfix
augroup quickfix
  autocmd!
  autocmd FileType qf setlocal wrap
augroup end

" auto-source .vimrc
augroup vimrc
  au!
  au BufWritePost $MYVIMRC source $MYVIMRC
augroup end

" start terminal-mode in insert-mode
augroup term_startinsert
  au!
  autocmd TermOpen,BufWinEnter,BufEnter term://* startinsert
augroup end

" }}}
" filetype {{{

augroup ft_go
  au!
  au FileType go nnoremap <silent> <C-t> :GoAlternate<CR>
  au FileType go nnoremap <silent> <Leader>h :GoDoc<CR>
  au FileType go nnoremap <silent> <Leader>t :GoTest<CR>
  au FileType go nnoremap <silent> <Leader>r :GoRun<CR>
  au FileType go nnoremap <silent> <Leader>0 :TagbarToggle<CR>
  au FileType go inoreabbrev iferr if err != nil {<CR>log.Fatal(err)<CR>}
  au FileType go let g:tagbar_width=60
augroup end

augroup ft_ruby
  au!
  au FileType ruby nnoremap <leader>r :w<CR>:!ruby %<CR>
  au FileType ruby setlocal omnifunc=rubycomplete#Complete
  au FileType ruby compiler ruby
  au FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
  au FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
  au FileType ruby,eruby let g:rubycomplete_rails = 1
augroup end

augroup ft_python
  au!
  au FileType python nnoremap <F5> :sp term:///usr/bin/env python3 %<CR>
  au FileType python nnoremap <leader>r :w<CR>:py3file %<CR>
  au FileType python set equalprg=autopep8\ -
augroup end

augroup ft_autohotkey
  au!
  au FileType autohotkey setlocal sw=4 sts=4 ts=4
augroup end

augroup ft_sql
  au!
  au FileType sql setlocal sw=4 sts=4 ts=4
augroup end

augroup ft_kotlin
  au!
  au FileType kotlin set makeprg=kotlinc\ -script\ %
augroup end

augroup ft_sh
  au!
  au FileType sh setlocal textwidth=0
  au FileType sh nnoremap <F5> :sp term:///usr/bin/env bash %<CR>
  au FileType sh nnoremap <Leader>r :sp term:///usr/bin/env bash %<CR>
augroup end

augroup ft_zsh
  au!
  au FileType zsh nnoremap <F5> :sp term:///usr/bin/env zsh %<CR>
  au FileType zsh nnoremap <Leader>r :sp term:///usr/bin/env zsh %<CR>
augroup end

augroup ft_json
  au!
  au FileType json set nowrap
  au FileType json nnoremap <Leader>f :%!python3 -m json.tool<CR>
augroup end

augroup ft_applescript
  au!
  au FileType applescript nnoremap <Leader>r :sp term:///usr/bin/env osascript %<CR>
augroup end

augroup ft_gitconfig
  au!
  au FileType gitconfig set noexpandtab
augroup end

augroup ft_gitcommit
  au!
  au FileType gitcommit exec 'au VimEnter * startinsert!'
augroup end

augroup ft_groovy
  au!
  au BufRead Jenkinsfile set ft=groovy
augroup end

