" This may be messed around with by dotfiles/setup.sh
" c30aa1879bc864389e1f88f1562751d3

set nocompatible              " be iMproved, required
"filetype off                  " required


"let g:pymode_python='python3'
set backspace=2
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

Plugin 'gmarik/Vundle.vim'
Plugin 'docunext/closetag.vim'
Plugin 'othree/html5.vim'
"Plugin 'wookiehangover/jshint.vim'
"Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-fugitive'
Plugin 'klen/python-mode'
Plugin 'nanotech/jellybeans.vim'
Plugin 'ervandew/supertab'
Plugin 'kien/ctrlp.vim'
Bundle 'jalcine/cmake.vim'

syntax on
set tabstop=13
set shiftwidth=4
set textwidth=80
set softtabstop=4
set expandtab
set modeline
set viminfo='100,<100,s10,h
set showcmd
set showmatch
set ignorecase
set mouse=a

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
noremap <C-n> :NERDTreeToggle<CR>
noremap <C-f> :NERDTreeFind<CR>
noremap <C-c> :CtrlPTag<CR>
noremap <C-x> :Make<Up><CR>

" Command Make will call make and then cwindow which
" opens a 3 line error window if any errors are found.
" If no errors, it closes any open cwindow.
:command -nargs=* Make make <args> | cwindow 3
:command StripSpace %s/\s\+$//g

colors jellybeans
set laststatus=2
set nofoldenable
set completeopt-=preview


autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Deactivate rope lookups
let g:pymode_rope_lookup_project = 0

" Indent HTML by two spaces
"autocmd Filetype html setlocal ts=2 sts=2 sw=2
