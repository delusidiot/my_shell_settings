call plug#begin('~/.vim/plugged')
Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'
call plug#end()

" charset
set encoding=utf-8

" indents
set autoindent
set smartindent

set t_Co=256
syntax on

" setting
set ruler
set nu

" vim theme
colorscheme gruvbox
set bg=dark
let g:airline_theme='violet'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#buffer_nr_show=1
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#formatter='unique_tail'

" git
set updatetime=100

nmap <C-b> <C-w>
nmap <F9> :NERDTreeToggle<cr>
