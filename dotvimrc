"[.vimrc]
    version 7.0
    set nocompatible
"[ editing ]
    set shiftwidth=4
    set tabstop=4
    set autoindent
    set expandtab
    " CH added 05.12.2017
    set smarttab
    "set smartindent
    "set bs=2
    set backspace=indent,eol,start
    ":fixdel
    set t_kb=^?
    " the above is done by 'bs'
    " the above is done by ctrl+v+H
    set number
    set encoding=utf-8
    filetype indent on
"[ misc ]
    set showmatch
    set showmode
    set history=50
"[ syntax ]
    "set syntax=c
    syntax on

    au BufNewFile,BufRead *.sv set filetype=v
    au BufNewFile,BufRead *.v set filetype=v
"[ ruler ]
    set ruler
    set showcmd

"[ status ]
    highlight User1 ctermfg=Red
    highlight User2 term=underline cterm=underline ctermfg=Green
    highlight User3 term=underline cterm=underline ctermfg=Yellow
    highlight User4 term=underline cterm=underline ctermfg=white
    highlight User5 ctermfg=cyan
    highlight User6 ctermfg=white
    set laststatus=2
    "set statusline

    set hlsearch
    highlight comment ctermfg=cyan
    highlight search ctermbg=yellow
    highlight search ctermfg=black
    highlight ColorColumn ctermbg=cyan
    "set cc=80
    set vb

"[ open to the same line when last open ]
    if has("autocmd")
        au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("