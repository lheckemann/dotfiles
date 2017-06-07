let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
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
colors pablo
silent! colors jellybeans

let g:deoplete#enable_at_startup=1

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

"tnoremap <C-w> <C-\><C-n><C-w>
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l
