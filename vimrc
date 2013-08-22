call pathogen#incubate()
call pathogen#helptags()

" Break vi compatibility
set nocompatible

"""""""""""""""""""""""""""""""""""""""""
" Basic Interface Settings
"""""""""""""""""""""""""""""""""""""""""
set ruler               " Show the ruler
set cmdheight=2         " Make the command window heighgh 2 high
set ignorecase          " Ignore case when searching
set smartcase           " Ignore ignorecase if uppercase values are present
set hlsearch            " Highlight all search results
set showmatch           " Show matching brackets
set noerrorbells        " No ding on error
set novisualbell        " Don't give a visual indicator
filetype plugin on
filetype indent on

"""""""""""""""""""""""""""""""""""""""""
" Colors & Fonts
"""""""""""""""""""""""""""""""""""""""""
syntax on               " Turn on syntax highlighting
colorscheme desert
set background=dark
set encoding=utf8

" Special Syntax Highlighting

"""""""""""""""""""""""""""""""""""""""""
" Tabstops & Text interaction
"""""""""""""""""""""""""""""""""""""""""
set expandtab           " Use spaces instead of tab
set smarttab            " Turn on smart tab
set shiftwidth=4        " 1 tab == 4 spaces
set tabstop=4           " 1 tab == 4 spaces
set softtabstop=4       " 1 tab == 4 spaces during <bs>
set wrap                " Wrap lines when they go past the end
"set number              " Show line numbers


" Turn on highlighting of white space that shouldn't be there.
highlight ExtraWhiteSpace ctermbg=red guibg=red
match ExtraWhiteSpace /s\+$|\t/
autocmd BufWinEnter * match ExtraWhiteSpace /\s\+$/
autocmd InsertEnter * match ExtraWhiteSpace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhiteSpace /\s\+$/
autocmd BufWinLeave * call clearmatches()

"""""""""""""""""""""""""""""""""""""""""
" Set encodings
"""""""""""""""""""""""""""""""""""""""""
