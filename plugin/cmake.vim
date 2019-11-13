"if exists('cmake_plugin_loaded') | finish | endif
let g:cmake_plugin_loaded = 1

function! s:execute(object)
  for key in ['keyword', 'match', 'region', 'cluster', 'highlight']
    for cmd in get(a:object, key, [])
      execute join(cmd, ' ')
    endfor
  endfor
endfunction

function! CMakeGenerateSyntax()
  let paths = cmake#json#find()
  " TODO: Place hash check here? Or possible before the call to #find
  for path in paths
    let object = cmake#json#load(path)
    if !has_key(object, '@type') | continue | endif
    if object['@type'] == 'property'
      call s:execute(cmake#syntax#property(object))
    elseif object['@type'] == 'variable'
      call s:execute(cmake#syntax#variable(object))
    elseif object['@type'] == 'module'
      call s:execute(cmake#syntax#module(object))
    elseif object['@type'] == 'command'
      call s:execute(cmake#syntax#command(object))
    elseif object['@type'] == 'include'
      call s:execute(cmake#syntax#include(object))
    endif
  endfor
endfunction

function! s:cmake_find_build()
endfunction

" TODO: Change the autoload functions to be cmake#cli
command! -nargs=* CMakeConfigure call cmake#configure(<f-args>)
command! -nargs=* CMakePackage call cmake#package(<f-args>)
command! -nargs=* CMakeBuild call cmake#build(<f-args>)
command! -nargs=* CMakeClean call cmake#clean(<f-args>)
command! -nargs=* CMakeTest call cmake#test(<f-args>)
command! -nargs=* CMakeRun call cmake#run(<f-args>)
command! -nargs=+ CMake call cmake#cmd(<q-args>)
