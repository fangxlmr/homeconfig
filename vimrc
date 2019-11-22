""""""""""""""""""""""""""""""""""""""""
" Filename:
"   vimrc.vim
"   This file config vim with basic options and plugins.
"
" Maintainer:
"   Fang Xiaoliang - fangxlmr <fangxlmr@foxmail.com>
"
" Sections:
"----------------Basics-----------------
"   => General
"   => VIM user interface
"   => Text, tab and indentation related
"   => Visual mode related
"   => Moving around
"   => Helpers
"   => Misc
"--------------Plugins------------------
"   => Auto completion
"   => Languages
"   => User interface & Color scheme
"   => Navigation in project
"   => Search, replace and multi-select
"   => Other
""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""
" => General
""""""""""""""""""""""""""""""""""""""""
" Set how many lines of history VIM has to remember
set history=500

" Define <leader>
let mapleader=","

" Map kj to ESC
inoremap kj <ESC>

" Enable filetype plugin and indent
filetype plugin indent on

" Enable mouse operation
set mouse=a

" Enable buffers hidden
set hidden

""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable
syntax on

" Always show current positon
set ruler

" Show line number
set number

" Highlight search results
set hlsearch

" Ignore case when search
set ignorecase

" Try to be smart about cases when searching
set smartcase

" Set color when used in Tmux
if &term == "screen"
      set t_Co=256
endif

set background=dark

" Disable scrollbars
set guioptions-=r
set guioptions-=R
set guioptions-=l
set guioptions-=L

" Disable cursor blinking
" Also need to disable cursor blink of console
set gcr=a:block-blinkon0

" Always show the status line
set laststatus=2

""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indentation related
""""""""""""""""""""""""""""""""""""""""
highlight SpecialKey ctermfg=red
set list
set listchars=tab:>-
augroup default_filetype
    autocmd!
    " Default tab and indentation behavior
    set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
    set backspace=indent,eol,start
    set autoindent
augroup END

augroup config_filetype
    autocmd!
    " For yaml/toml
    au BufNewFile,BufRead *.toml setf toml
    autocmd FileType yaml,toml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
    " For json
    autocmd FileType json setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
augroup END

augroup lang_filetype
    autocmd!
    " For golang/python/rust
    autocmd FileType go,python,rust setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
    " For shell
    autocmd FileType sh,zsh,csh setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
    " For Makefile
    autocmd FileType make setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
augroup END

""""""""""""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>?<C-R>=@/<CR><CR>"

" Shift lines with tab
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_

" Stay selected after indentation is done
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

""""""""""""""""""""""""""""""""""""""""
" => Moving around
""""""""""""""""""""""""""""""""""""""""
" Smart ways to move between windows
nnoremap <C-J> <C-W>j
nnoremap <C-K> <C-W>k
nnoremap <C-H> <C-W>h
nnoremap <C-L> <C-W>l
" The following is also workable
"map <C-H> :wincmd h<CR>
"map <C-J> :wincmd j<CR>
"map <C-K> :wincmd k<CR>
"map <C-L> :wincmd l<CR>

" Map E to the end of current line
noremap E $
" Map B to the begin of current line
noremap B ^

" Bash like keys for the command line
cnoremap <C-A> <HOME>
cnoremap <C-E> <END>

""""""""""""""""""""""""""""""""""""""""
" => Helpers
""""""""""""""""""""""""""""""""""""""""
function! CmdLine(str)
        call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction


""""""""""""""""""""""""""""""""""""""""
" => Misc
""""""""""""""""""""""""""""""""""""""""
" Find tag files up to root recursively
set tags=tags;/

" Cscope config
if has("cscope")
    set csprg=/usr/bin/cscope
    set csto=0
    set cst
    set nocsverb
    " add any database in current directory
    if filereadable("cscope.out")
        cs add cscope.out
        " else add database pointed to by environment
    elseif $CSCOPE_DB != ""
        cs add $CSCOPE_DB
    endif
    set csverb
endif

"Highlight trailing white spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

call plug#begin('~/.vim/plugged')
""""""""""""""""""""""""""""""""""""""""
" => Auto completion
""""""""""""""""""""""""""""""""""""""""
" Code auto-completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neoclide/coc-json'
Plug 'neoclide/coc-yaml'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'

" Code snippets
Plug 'honza/vim-snippets'

inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
let g:coc_snippet_next = '<tab>'

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

""""""""""""""""""""""""""""""""""""""""
" => Languages
""""""""""""""""""""""""""""""""""""""""
" Rust-lang support
Plug 'rust-lang/rust.vim'

" Golang support
Plug 'fatih/vim-go'

""""""""""""""""""""""""""""""""""""""""
" => User interface & Color scheme
""""""""""""""""""""""""""""""""""""""""
" Vim interface
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='simple'

" Vim color scheme
Plug 'altercation/vim-colors-solarized'
"silent! colorscheme solarized

" Tmux interface
Plug 'edkolev/tmuxline.vim'

""""""""""""""""""""""""""""""""""""""""
" => Navigation in project
""""""""""""""""""""""""""""""""""""""""
" Side navigation bar
Plug 'scrooloose/nerdtree'
map <leader>n :NERDTreeToggle<CR>
let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$']

" Start NERDTree if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Close vim if only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

Plug 'majutsushi/tagbar'
nmap <leader>t :TagbarToggle<CR>
" Move cursor to tagbar window automatically
let g:tagbar_autofocus=1

" VIM marks
Plug 'kshenoy/vim-signature'

""""""""""""""""""""""""""""""""""""""""
" => Search, replace and multi-select
""""""""""""""""""""""""""""""""""""""""
Plug 'mileszs/ack.vim'

Plug 'dyng/ctrlsf.vim'
" Search word under the cursor globally
nnoremap <leader>s :CtrlSF<CR>
" Show command line for 'grep'
nmap <leader>g <Plug>CtrlSFPrompt
" If want to switch result window between normal view and compact view,
" Press M in result window

Plug 'yggdroot/LeaderF', { 'do': './install.sh' }
let g:Lf_ShortcutF = '<leader>f'

" Change the highlight of matched string
highlight Lf_hl_match gui=bold guifg=Blue cterm=bold ctermfg=21
highlight Lf_hl_matchRefine  gui=bold guifg=Magenta cterm=bold ctermfg=201


""""""""""""""""""""""""""""""""""""""""
" => Other
""""""""""""""""""""""""""""""""""""""""
" Autoload cscope
Plug 'vim-scripts/autoload_cscope.vim'

" Asynchronous Lint Engine
Plug 'dense-analysis/ale'
let g:airline#extensions#ale#enabled = 1

" Easy commenter
Plug 'scrooloose/nerdcommenter'
" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" Use Ctrl+/ to comment and Ctrl-\ to uncomment.
" Vim registers <C-/> as <C-_> for some reason.
map <C-_> <plug>NERDCommenterComment
map <C-\> <plug>NERDCommenterUncomment

" Sugar for unix shell command
Plug 'tpope/vim-eunuch'

call plug#end()

