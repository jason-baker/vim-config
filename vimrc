" Break compatibility/sane reset
set nocompatible

" Get the operating system on non-windows machines
let os="win"
if !has('win32') && !has('win64')
    let os =substitute(system('uname'), '\n', '', '')
endif

"""""""""""""""""""""""""""""""""""""""""
" Set backup directory & os specific info
"""""""""""""""""""""""""""""""""""""""""

if has('win32') || has('win64')
    set runtimepath=$HOMEDRIVE$HOMEPATH/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOMEDRIVE$HOMEPATH/.vim/after
    set backupdir=$HOMEDRIVE$HOMEPATH/.vim/tmp/bak  " where to put backup files
    set directory=$HOMEDRIVE$HOMEPATH/.vim/tmp/swp  " directory to place swap files in
else
    set backupdir=$HOME/.vim/tmp/bak    " where to put backup files
    set directory=$HOME/.vim/tmp/swp    " directory to place swap files in
end

" Infect with pathogen
call pathogen#incubate()
call pathogen#helptags()

"""""""""""""""""""""""""""""""""""""""""
" Filetype detection information
"""""""""""""""""""""""""""""""""""""""""
filetype plugin on
filetype indent on

set backup          " turn on backup files.
set writebackup     " Update the backup file on write.
set swapfile        " Keep swap files.

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
let g:solarized_italic=0
if !has("gui_window")
    if (os == 'Darwin' || os == 'Mac')
        colorscheme desert
        set background=light
    else
        let g:solarized_termcolors=256
        set t_Co=256
        set background=dark
        colorscheme solarized
    end
else
    colorscheme solarized
end

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
" Tabstops & Text interaction
"""""""""""""""""""""""""""""""""""""""""
set expandtab                       " Use spaces instead of tab
set smarttab                        " Turn on smart tab
set shiftwidth=4                    " 1 tab == 4 spaces
set tabstop=4                       " 1 tab == 4 spaces
set softtabstop=4                   " 1 tab == 4 spaces during <bs>
set wrap                            " Wrap lines when they go past the end
set number                          " Show line numbers
set backspace=indent,eol,start      " Allow backspacing over autoindent, line breaks and start of insert action

" Data from other vim to be merged later
"
"set guifont=consolas:h11
"set fileencodings=ucs-bom,utf-8,default
"" set guifont=Consolas:h11:cANSI

"""""""""""""""""""""""""""""""""""""""""
" Set encodings
"""""""""""""""""""""""""""""""""""""""""
set encoding=utf8


"""""""""""""""""""""""""""""""""""""""""
" Enhanced functionality
"""""""""""""""""""""""""""""""""""""""""

" Return to last edit position when opening files (You want this!)
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
set viminfo^=%          " Remember info about open buffers on close


" With a map leader it's possible to do extra key combinations
let mapleader = "\\"
let g:mapleader = "\\"


