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
set smartindent
set textwidth=80
set shada='100,<100,s10,h
set scrolloff=1
set splitbelow splitright
set incsearch
set wildmenu
set formatoptions+=j
set notitle

let g:airline_powerline_fonts=1
let g:jellybeans_background_color_256=233
let g:airline_theme='jellybeans'
if exists("$TMUX")
    " normal mode: block
    let &t_EI = "\<Esc>[0 q"
    " insert mode: vertical line
    let &t_SI = "\<Esc>[5 q"
endif
colors pablo
silent! colors jellybeans

let NERDTreeIgnore=['\~$', '\.pyc$']
noremap <C-n> :NERDTreeToggle<CR>
noremap <C-f> :NERDTreeFind<CR>
noremap <C-c> :CtrlPTag<CR>
noremap <Tab> gt
command! StripSpace %s/\s\+$//ge
command! W w
command! Wq wq
command! -nargs=1 Spaces set shiftwidth=<args> softtabstop=<args> tabstop=17 expandtab autoindent
command! -nargs=1 Tabs set shiftwidth=<args> softtabstop=<args> tabstop=<args> noexpandtab autoindent
Spaces 4
command! PdPreview !x-www-browser "data:text/html;base64,$(pandoc % -t html5 --standalone | base64)"
