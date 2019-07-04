call pathogen#infect()
  2 syntax enable
  3 filetype plugin on
  4 set number
  5 let g:go_disable_autoinstall = 0
  6
  7 " Highlight
  8 let g:go_highlight_functions = 1
  9 let g:go_highlight_methods = 1
 10 let g:go_highlight_structs = 1
 11 let g:go_highlight_operators = 1
 12 let g:go_highlight_build_constraints = 1
 13
 14
 15 " Tags
 16
 17  let g:tagbar_type_go = {
 18     \ 'ctagstype' : 'go',
 19     \ 'kinds'     : [
 20         \ 'p:package',
 21         \ 'i:imports:1',
 22         \ 'c:constants',
 23         \ 'v:variables',
 24         \ 't:types',
 25         \ 'n:interfaces',
 26         \ 'w:fields',
 27         \ 'e:embedded',
 28         \ 'm:methods',
 29         \ 'r:constructor',
 30         \ 'f:functions'
 31     \ ],
 32     \ 'sro' : '.',
 33     \ 'kind2scope' : {
 34         \ 't' : 'ctype',
 35         \ 'n' : 'ntype'
 36     \ },
 37     \ 'scope2kind' : {
 38         \ 'ctype' : 't',
 39         \ 'ntype' : 'n'
 40     \ },
 41     \ 'ctagsbin'  : 'gotags',
 42     \ 'ctagsargs' : '-sort -silent'
 43 \ }
 44
 45 nmap <F8> :TagbarToggle<CR>
 46 color evening
    set csre
 47
 48 source ~/.vim/bundle/cscope_macros.vim
 49 map <F2> :!ls<CR>
 50 let g:netrw_browse_split=4
 51 let g:netrw_winsize = -100
~