" if you don't know the special character code for something do:
" i -> ctrl+k -> key [combination]

" this remaps alt+<Right> -> f -> w(ord)
" word is the command to go forward with word skip
map f w

" ctrl+A=start and ctrl+E=end shortcuts
map <C-A> <Home>
map <C-E> <End>

"map <S-Left> <Home>
"map <S-Right> <End>

"" enables mouse scrolling & selection
" set mouse=a

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

set backspace=indent,eol,start  " more powerful backspacing

" PATCH: to fix the escape time problem with insert mode. on versions of vim<v8
" Code from: ttp://stackoverflow.com/questions/5585129/pasting-code-into-terminal-window-into-vim-on-mac-os-x
if &term =~ "xterm.*"
    let &t_ti = &t_ti . "\e[?2004h"
    let &t_te = "\e[?2004l" . &t_te
    function! XTermPasteBegin(ret)
        set pastetoggle=<Esc>[201~
        set paste
        return a:ret
    endfunction 
    map <expr> <Esc>[200~ XTermPasteBegin("i")
    imap <expr> <Esc>[200~ XTermPasteBegin("")
    vmap <expr> <Esc>[200~ XTermPasteBegin("c")
    cmap <Esc>[200~ <nop>
    cmap <Esc>[201~ <nop>
endif
