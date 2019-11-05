if exists("b:ftplugin") | finish | endif
let b:ftplugin = 1

" This allows generator expressions to act like matching pairs
setlocal matchpairs+=<:>
" allows for comments to format correctly
setlocal commentstring=#\ %s
setlocal comments=:#
setlocal suffixesadd=.cmake

setlocal define='\v^\s*macro\s*(\w+'
