" This may be messed around with by dotfiles/setup.sh
" c30aa1879bc864389e1f88f1562751d3

set nocompatible              " be iMproved, required
"filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
"Plugin 'docunext/closetag.vim'
"Plugin 'othree/html5.vim'
"Plugin 'wookiehangover/jshint.vim'
"Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-fugitive'
Plugin 'nanotech/jellybeans.vim'
Plugin 'ervandew/supertab'
Plugin 'kien/ctrlp.vim'
Plugin 'davidhalter/jedi-vim'
Plugin 'justmao945/vim-clang'
Plugin 'ludovicchabant/vim-lawrencium'
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
noremap <C-n> :NERDTreeToggle<CR>
noremap <C-f> :NERDTreeFind<CR>
noremap <C-c> :CtrlPTag<CR>
noremap <C-x> :Make<Up><CR>
noremap <Tab> gt

" Command Make will call make and then cwindow which
" opens a 3 line error window if any errors are found.
" If no errors, it closes any open cwindow.
command! -nargs=* Make make <args> | cwindow 3
command! StripSpace %s/\s\+$//ge
command! W w
command! Wq wq
command! -nargs=1 Spaces set shiftwidth=<args> softtabstop=<args> tabstop=17 expandtab autoindent
command! -nargs=1 Tabs set shiftwidth=<args> softtabstop=<args> tabstop=<args> noexpandtab autoindent
command! PdPreview !x-www-browser "data:text/html;base64,$(pandoc % -t html5 --standalone | base64)"

let g:jellybeans_background_color_256=233
let g:airline_theme='jellybeans'
colorscheme jellybeans

autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

syntax on
set backspace=2
set colorcolumn=80,100,120
set completeopt=menu,preview,longest
set expandtab
set ignorecase
set laststatus=2 " Always show a status line
set modeline
set mouse=a
set nofoldenable
set showcmd
set showmatch " Bracket matching highlight
set shiftwidth=4
set softtabstop=4
set tabstop=13
set smartindent
set textwidth=80
set viminfo='100,<100,s10,h
set scrolloff=1
set splitbelow splitright
set incsearch
set wildmenu
set formatoptions+=j
set notitle
" Indent HTML by two spaces
"autocmd Filetype html setlocal ts=2 sts=2 sw=2
let g:airline_powerline_fonts=1
let NERDTreeIgnore=['\~$', '\.pyc$']

if exists("$TMUX")
    " normal mode: block
    let &t_EI = "\<Esc>[0 q"
    " insert mode: vertical line
    let &t_SI = "\<Esc>[6 q"
endif
