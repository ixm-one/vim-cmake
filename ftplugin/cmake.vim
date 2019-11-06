if exists("b:ftplugin") | finish | endif
let b:ftplugin = 1

" Path to plugin root
let s:plugin = expand('<sfile>:p:h:h')
let s:dictionary = printf("%s/sundry/dictionary.txt", s:plugin)
let s:thesaurus = printf("%s/sundry/thesaurus.txt", s:plugin)

" This allows generator expressions to act like matching pairs
setlocal matchpairs+=<:>
" allows for comments to format correctly
setlocal commentstring=#\ %s
setlocal comments=bfs:#[[,m:\ ,e:]],b:#
setlocal suffixesadd=.cmake
setlocal path+=cmake

" TODO: Add includeexpr
" TODO: Add formatexpr
" TODO: Add foldexpr


" These are a bit more fragile when it comes to setting values, so we use the
" let &l: approach :)

let &l:include ='\v^\s*include\(\zs\w+\ze\)'
let &l:define = '\v^\s*(macro|function)\s*\('

let &l:dictionary = s:dictionary
let &l:thesaurus = s:thesaurus
