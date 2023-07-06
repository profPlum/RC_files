" if you don't know the special character code for something do:
" i -> ctrl+k -> key [combination]

" this remaps alt+<Right> -> f -> w(ord)
" word is the command to go forward with word skip
map f w
"map <S-Left> <Home>
"map <S-Right> <End>

map <C-A> <Home>
map <C-E> <End>

set hlsearch
" highlight search

"set expandtab
"set tabstop=4
set shiftround  " Round indent to multiple of 'shiftwidth'
set smartindent " Do smart indenting when starting a new line
set autoindent  " Copy indent from current line, over to the new line
set ts=4 sts=4 sw=4 expandtab
" ts=tabstop, sts=softtabstop, sw=shiftwidth
" ts==sts if you prefer to use tabs (you do)
" see: http://vimcasts.org/episodes/tabs-and-spaces/
syntax on
colorscheme desert
