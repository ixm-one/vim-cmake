" This file contains functions related to locating various bits of information
" regarding the CMake project, as well as plugin information.

" Configuration settings that affect project root lookup:
" * cmake_locate_stopdirs -- list of paths to not look beyond
" * cmake_locate_findfunc -- function to execute instead of cmake#locate#root
function! s:file(name)
  return findfile(a:name, printf("%s%s", expand('%:p'), s:stopdirs()))
endfunction

function! s:dir(name)
  return finddir(a:name, printf("%s%s", expand('%:p'), s:stopdirs()))
endfunction

function! s:stopdirs()
  let paths = map(get(g:, 'cmake_locate_stopdirs', []), {_, val -> resolve(val) })
  return printf(";%s", join(paths, ";'))
endfunction

function! s:vscode()
  return [fnamemodify(s:dir('.vscode'), ':h')]
endfunction

function! s:git()
  return [fnamemodify(s:dir('.git'), ':h')]
endfunction

function! s:readme()
  let names = ['README.md', 'README.rst', 'README.txt', 'README']
  return map(names, {_, val -> fnamemodify(s:file(val), ':h') })
endfunction

function! cmake#locate#root()
endfunction
