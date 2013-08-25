call pathogen#incubate()
call pathogen#helptags()

" Break vi compatibility
set nocompatible

"""""""""""""""""""""""""""""""""""""""""
" Set backup directory
"""""""""""""""""""""""""""""""""""""""""

if has('win32') || has('win64')
    set backupdir=$HOMEDRIVE$HOMEPATH/AppData/LocalLow/Vim/tmp/bak  " where to put backup files
    set directory=$HOMEDRIVE$HOMEPATH/AppData/LocalLow/Vim/tmp/swp  " directory to place swap files in
else
    set backupdir=$HOME/.vim/tmp/bak    " where to put backup files
    set directory=$HOME/.vim/tmp/swp    " directory to place swap files in
end

"""""""""""""""""""""""""""""""""""""""""
" Basic Interface Settings
"""""""""""""""""""""""""""""""""""""""""
set ruler               " Show the ruler
set cmdheight=2         " Make the command window heighgh 2 high
set ignorecase          " Ignore case when searching
set smartcase           " Ignore ignorecase if uppercase values are present
set incsearch           " Search incrementally as it is typed
set hlsearch            " Highlight all search results
set showmatch           " Show matching brackets
set noerrorbells        " No ding on error
set novisualbell        " Don't give a visual indicator
set autoindent          " Continue indenting when new lines are hit
set smartindent         " Do indenting in and out based on language settings

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

" Change the display for listing whitespace
" @TODO

" Turn on highlighting of white space that shouldn't be there.
highlight ExtraWhiteSpace ctermbg=red guibg=red
match ExtraWhiteSpace /s\+$|\t/
autocmd BufWinEnter * match ExtraWhiteSpace /\s\+$/
autocmd InsertEnter * match ExtraWhiteSpace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhiteSpace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Turn on highlighting of tab characters that shouldn't be there.
highlight TabWhitespace ctermbg=red guibg=red
match TabWhitespace /\t\+/
autocmd BufWinEnter * match TabWhitespace /\s\+$/
autocmd InsertEnter * match TabWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match TabWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

set listchars=trail:#,extends:>,precedes:<
set list

"""""""""""""""""""""""""""""""""""""""""
" File specific information
"""""""""""""""""""""""""""""""""""""""""
filetype plugin on
filetype indent on

" Data from other vim to be merged later
"
"set guifont=consolas:h11
"set fileencodings=ucs-bom,utf-8,default
"set enc=utf-8
"" set guifont=Consolas:h11:cANSI

"""""""""""""""""""""""""""""""""""""""""
" Set encodings
"""""""""""""""""""""""""""""""""""""""""
