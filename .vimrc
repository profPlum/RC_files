" if you don't know the special character code for something do:
" i -> ctrl+k -> key [combination]

" this remaps alt+<Right> -> f -> w(ord)
" word is the command to go forward with word skip
map f w
"map <S-Left> <Home>
"map <S-Right> <End>

map <C-A> <Home>
map <C-E> <End>

" automatically fold based on syntax/language being used!
set foldmethod=indent "syntax
set hlsearch
" highlight search

"set smartindent " Do smart indenting when starting a new line
"set autoindent  " Copy indent from current line, over to the new line
filetype plugin indent on " better than smart or auto-indent
set shiftround  " Round indent to multiple of 'shiftwidth'
set ts=4 sts=4 sw=4 expandtab
" ts=tabstop, sts=softtabstop, sw=shiftwidth
" ts==sts if you prefer to use tabs (you do)
" see: http://vimcasts.org/episodes/tabs-and-spaces/
syntax on
colorscheme desert


" PATCH: to fix the escape time problem with insert mode. on versions of vim<v8
" Code from:
" http://stackoverflow.com/questions/5585129/pasting-code-into-terminal-window-into-vim-on-mac-os-x
" then https://coderwall.com/p/if9mda
" and then https://github.com/aaronjensen/vimfiles/blob/59a7019b1f2d08c70c28a41ef4e2612470ea0549/plugin/terminaltweaks.vim
"
" Docs on bracketed paste mode:
" http://www.xfree86.org/current/ctlseqs.html
" Docs on mapping fast escape codes in vim
" http://vim.wikia.com/wiki/Mapping_fast_keycodes_in_terminal_Vim

if exists("g:loaded_bracketed_paste")
  finish
endif
let g:loaded_bracketed_paste = 1

let &t_ti .= "\<Esc>[?2004h"
let &t_te = "\e[?2004l" . &t_te

function! XTermPasteBegin(ret)
  set pastetoggle=<f29>
  set paste
  return a:ret
endfunction

execute "set <f28>=\<Esc>[200~"
execute "set <f29>=\<Esc>[201~"
map <expr> <f28> XTermPasteBegin("i")
imap <expr> <f28> XTermPasteBegin("")
